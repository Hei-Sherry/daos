//
// (C) Copyright 2020 Intel Corporation.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// GOVERNMENT LICENSE RIGHTS-OPEN SOURCE SOFTWARE
// The Government's rights to use, modify, reproduce, release, perform, display,
// or disclose this software are subject to the terms of the Apache License as
// provided in Contract No. 8F-30005.
// Any reproduction of computer software, computer software documentation, or
// portions thereof marked with this legend must also reproduce the markings.
//
// +build firmware

package main

import (
	"strings"
	"testing"

	"github.com/daos-stack/daos/src/control/lib/control"
	"github.com/pkg/errors"
)

func TestFirmwareCommands(t *testing.T) {
	runCmdTests(t, []cmdTest{
		{
			"Query with no args defaults to all",
			"firmware query",
			strings.Join([]string{
				printRequest(t, &control.FirmwareQueryReq{
					SCM:  true,
					NVMe: true,
				}),
			}, " "),
			nil,
		},
		{
			"Query with SCM",
			"firmware query --type=scm",
			strings.Join([]string{
				printRequest(t, &control.FirmwareQueryReq{
					SCM: true,
				}),
			}, " "),
			nil,
		},
		{
			"Query with NVMe",
			"firmware query --type=nvme",
			strings.Join([]string{
				printRequest(t, &control.FirmwareQueryReq{
					NVMe: true,
				}),
			}, " "),
			nil,
		},
		{
			"Query with all",
			"firmware query --type=all",
			strings.Join([]string{
				printRequest(t, &control.FirmwareQueryReq{
					SCM:  true,
					NVMe: true,
				}),
			}, " "),
			nil,
		},
		{
			"Query with invalid type",
			"firmware query --type=none",
			"",
			errors.New("Invalid value `none' for option `-t, --type'. Allowed values are: nvme, scm or all"),
		},
		{
			"Update with no path",
			"firmware update --type=scm",
			"",
			errors.New("the required flag `-p, --path' was not specified"),
		},
		{
			"Update with no type",
			"firmware update --path=/doesnt/matter",
			"",
			errors.New("the required flag `-t, --type' was not specified"),
		},
		{
			"Update with invalid type",
			"firmware update --type=all --path=/doesnt/matter",
			"",
			errors.New("Invalid value `all' for option `-t, --type'. Allowed values are: nvme or scm"),
		},
		{
			"Update with SCM",
			"firmware update --type=scm --path=/dont/care",
			strings.Join([]string{
				printRequest(t, &control.FirmwareUpdateReq{
					FirmwarePath: "/dont/care",
					Type:         control.DeviceTypeSCM,
				}),
			}, " "),
			nil,
		},
		{
			"Update with NVMe",
			"firmware update --type=nvme --path=/dont/care",
			strings.Join([]string{
				printRequest(t, &control.FirmwareUpdateReq{
					FirmwarePath: "/dont/care",
					Type:         control.DeviceTypeNVMe,
				}),
			}, " "),
			nil,
		},
	})
}
