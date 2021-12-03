package sql1cv8

import (
	"fmt"
	"strconv"
)

// Объект метаданных
type Object struct {
	// Номер объекта в десятеричной системе
	Number string
	// Имя объекта в базе данных
	DBName string
	// Имя объекта в конфигурации
	CVName string
	// Параметры объекта
	Fields map[string]*Object
}

// RTRefInt возвращает ВидСсылки типа INT
func (o *Object) RTRefInt() (string, error) {
	_, err := strconv.ParseUint(o.Number, 0, 32)
	if err != nil {
		return "", err
	}
	return o.Number, nil
}

// RTRefBin возвращает ВидСсылки типа BINARY(4)
func (o *Object) RTRefBin() (string, error) {
	u, err := strconv.ParseUint(o.Number, 0, 32)
	if err != nil {
		return "", err
	}
	return fmt.Sprintf("0x%08X", u), nil
}

// Метаданные
type Metadata struct {
	// Версия метаданных
	Version string
	// Объекты метаданных первого уровня.
	// Это либо таблицы, либо какие-то констаты вроде типов полей для составных типов, значения перечислений и виды ссылок
	Tables map[string]*Object
}
