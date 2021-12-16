package sql1cv8

import (
	"encoding/json"
	"fmt"
	"os"
	"strconv"
)

// Object объект метаданных
type Object struct {
	UUID     string             // Идентификатор
	Number   string             // Номер объекта DBNames
	DBName   string             // Имя в базе данных
	CVName   string             // Имя в конфигурации
	Synonyms map[string]string  // Синонимы объекта
	Params   map[string]*Object // Параметры объекта
}

// RTRefInt возвращает ВидСсылки типа INT.
func (o *Object) RTRefInt() (string, error) {
	_, err := strconv.ParseUint(o.Number, 0, 32)
	if err != nil {
		return "", err
	}
	return o.Number, nil
}

// RTRefBin возвращает ВидСсылки типа BINARY(4).
func (o *Object) RTRefBin() (string, error) {
	u, err := strconv.ParseUint(o.Number, 0, 32)
	if err != nil {
		return "", err
	}
	return fmt.Sprintf("0x%08X", u), nil
}

// Metadata метаданные
type Metadata struct {
	Version string             // Версия метаданных
	Objects map[string]*Object // Объекты метаданных первого уровня. Это либо таблицы, либо какие-то констаты вроде типов полей для составных типов, значения перечислений и виды ссылок
}

// SaveToFile сохраняет метаданные в файл.
// В качестве параметров принимает строковую переменную:
// s - имя файла, в котором хранится кэш метаданных в формате json.
func (m Metadata) SaveToFile(s string) (err error) {
	b, err := json.Marshal(m)
	if err != nil {
		return
	}
	f, err := os.Create(s)
	if err != nil {
		return
	}
	defer f.Close()
	_, err = f.Write(b)
	if err != nil {
		return
	}
	return
}
