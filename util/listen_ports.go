package util

import (
	"os/exec"
	"regexp"
	"sort"
	"strconv"
	"strings"
)

func GetListenPorts(pid int) string {
	if pid <= 0 {
		return ""
	}

	ports := make(map[int]bool)

	cmd := exec.Command("lsof", "-nP", "-iTCP", "-sTCP:LISTEN", "-a", "-p", strconv.Itoa(pid))
	output, err := cmd.Output()
	if err == nil {
		lines := strings.Split(string(output), "\n")
		portRegex := regexp.MustCompile(`:(\d+)\s+\(LISTEN\)`)
		for _, line := range lines {
			matches := portRegex.FindStringSubmatch(line)
			if len(matches) >= 2 {
				if port, err := strconv.Atoi(matches[1]); err == nil {
					ports[port] = true
				}
			}
		}
	}

	result := make([]int, 0, len(ports))
	for port := range ports {
		result = append(result, port)
	}
	sort.Ints(result)

	if len(result) == 0 {
		return ""
	}

	portStrs := make([]string, len(result))
	for i, port := range result {
		portStrs[i] = strconv.Itoa(port)
	}
	return strings.Join(portStrs, ",")
}
