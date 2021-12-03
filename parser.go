package sql1cv8

import (
	"errors"
	"regexp"
	"strconv"
	"strings"
)

// Parse преобразует в тексте имена метаданных в имена базы данных.
// В качестве параметров принимает строковую переменную:
// src - текст запроса.
// Возвращает изменённый запрос res.
func (m Metadata) Parse(src string) (res string, err error) {
	buf := []string{}
	res = src

	res, buf = removeStringsAndComments(res, buf)
	res = markStatements(res)
	res = parseFullConstructions(m, res)
	res, err = parseWithBrackets(m, res)
	if err != nil {
		return "", err
	}
	res = restoreStringsAndComments(res, buf)

	return
}

func parseWithBrackets(m Metadata, src string) (res string, err error) {
	var (
		re   *regexp.Regexp
		open int
		inc  string
	)

	for {
		i := strings.Index(src, "(")
		j := strings.Index(src, ")")
		if i < 0 && j < 0 {
			if open > 0 {
				return "", errors.New("не закрыта скобка")
			}
			res += src
			break
		}
		if i < 0 {
			i = j + 1
		}
		if j < 0 {
			j = i + 1
		}
		if i < j {
			if open == 0 {
				res += src[:i+1]
				inc = ""
			} else {
				inc += src[:i+1]
			}
			src = src[i+1:]
			open++
		} else {
			if open == 0 {
				return "", errors.New("ошибочное закрытие скобки")
			}
			open--
			if open == 0 {
				inc += src[:j]
				s, err := parseWithBrackets(m, inc)
				if err != nil {
					return "", err
				}
				res += s + ")"
				src = src[j+1:]
			} else {
				inc += src[:j+1]
				src = src[j+1:]
			}
		}
	}

	re = regexp.MustCompile(`¡[^¡]+`)
	res = re.ReplaceAllStringFunc(res, func(s string) string {
		return parseWithAliases(m, s)
	})
	res = unmarkStatements(res)

	return
}

func markStatements(src string) string {
	re := regexp.MustCompile(`(?si)\b((?:select|bulk|insert|update|delete|merge)\s)`)
	return re.ReplaceAllString(src, `¡$1`)
}

func unmarkStatements(src string) string {
	return strings.ReplaceAll(src, "¡", "")
}

func parseFullConstructions(m Metadata, src string) string {
	re := regexp.MustCompile(`\[\$([\pL\w\.]+)\]\.\[\$([\pL\w\.]+)\]`)
	return re.ReplaceAllStringFunc(src, func(s string) string {
		a := re.FindStringSubmatch(s)
		tabname := a[1]
		colname := a[2]
		tableObject, ok := m.Tables[tabname]
		if !ok {
			return s
		}
		fieldObject, ok := tableObject.Fields[colname]
		if !ok {
			return s
		}
		return tableObject.DBName + "." + fieldObject.DBName
	})
}

func parseWithAliases(m Metadata, src string) string {
	var re *regexp.Regexp
	res := src

	aliases := map[string]string{}
	re = regexp.MustCompile(`(?si)(?:\.\.|\[dbo\]\.|\bdbo\.|[^\.])\[\$([\pL\w\.]+)\](?:\s+as\s+|\s+)(?:\[(.+?)\]|(\w+))`)
	for _, v := range re.FindAllStringSubmatch(res, -1) {
		tabname := v[1]
		aliasname := v[2] + v[3]
		aliases[aliasname] = tabname
	}

	re = regexp.MustCompile(`(?si)((?:\.\.|\[dbo\]\.|\bdbo\.|[^\.]))\[\$([\pL\w\.]+)\]`)
	res = re.ReplaceAllStringFunc(res, func(s string) string {
		a := re.FindStringSubmatch(s)
		prefix := a[1]
		tabname := a[2]
		tableObject, ok := m.Tables[tabname]
		if !ok {
			return s
		}
		return prefix + tableObject.DBName
	})

	re = regexp.MustCompile(`(?si)((?:\[(.+?)\]|(\w+))\.)\[\$([\pL\w\.]+)\]`)
	res = re.ReplaceAllStringFunc(res, func(s string) string {
		a := re.FindStringSubmatch(s)
		prefix := a[1]
		aliasname := a[2] + a[3]
		colname := a[4]
		tabname, ok := aliases[aliasname]
		if !ok {
			return s
		}
		tableObject, ok := m.Tables[tabname]
		if !ok {
			return s
		}
		fieldObject, ok := tableObject.Fields[colname]
		if !ok {
			return s
		}
		return prefix + fieldObject.DBName
	})

	return res
}

func restoreStringsAndComments(src string, buf []string) string {
	res := src
	for i := len(buf) - 1; i >= 0; i-- {
		old := "#" + strconv.Itoa(i)
		new := buf[i]
		res = strings.Replace(res, old, new, 1)
	}
	return res
}

func removeStringsAndComments(src string, buf []string) (string, []string) {
	var (
		open     int
		sub, clr string
		res, com string
	)

	for {
		if open == 0 {
			i1 := index(src, "/*")
			i2 := index(src, "--")
			i3 := index(src, "'")
			i4 := index(src, "\"")
			i := min(i1, i2, i3, i4)
			if i == len(src) {
				res += src
				break
			}
			sub = ""
			switch i {
			case i1:
				com = "/*"
				sub = "/*"
				clr = "*/"
			case i2:
				com = "--"
				clr = "\n"
			case i3:
				com = "'"
				clr = "'"
			case i4:
				com = "\""
				clr = "\""
			}
			res += src[:i]
			src = src[i+len(com):]
			open++
		} else {
			i := index(src, sub) + len(sub)
			j := index(src, clr) + len(clr)
			k := min(i, j, len(src))
			if k == len(src) {
				com += src
				buf = append(buf, com)
				res += "#" + strconv.Itoa(len(buf)-1)
				break
			}
			com += src[:k]
			src = src[k:]
			if i < j {
				open++
			} else {
				open--
				if open == 0 {
					buf = append(buf, com)
					res += "#" + strconv.Itoa(len(buf)-1)
				}
			}
		}
	}
	return res, buf
}

func index(s, substr string) int {
	if len(substr) == 0 {
		return len(s)
	}
	i := strings.Index(s, substr)
	if i < 0 {
		return len(s)
	}
	return i
}

func min(i ...int) int {
	r := 2147483647
	for _, v := range i {
		if r > v {
			r = v
		}
	}
	return r
}
