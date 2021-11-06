// Документация по теме:
// https://its.1c.ru/db/metod8dev/content/1798/hdoc
// https://its.1c.ru/db/metod8dev/content/1828/hdoc

package sql1cv8

import (
	"fmt"
	"strconv"
)

type Object struct {
	Number string
	DBName string
	CVName string
	Fields map[string]*Object
}

func (o *Object) RTRefInt() (string, error) {
	_, err := strconv.ParseUint(o.Number, 0, 32)
	if err != nil {
		return "", err
	}
	return o.Number, nil
}

func (o *Object) RTRefBin() (string, error) {
	u, err := strconv.ParseUint(o.Number, 0, 32)
	if err != nil {
		return "", err
	}
	return fmt.Sprintf("0x%08X", u), nil
}

type Metadata struct {
	Version string
	Tables  map[string]*Object
}
