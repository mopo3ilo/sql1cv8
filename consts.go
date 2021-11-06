package sql1cv8

// Типы полей
var consts = map[string]string{
	"Тип.Тип":       "0x01",
	"Тип.Булево":    "0x02",
	"Тип.Число":     "0x03",
	"Тип.Дата":      "0x04",
	"Тип.Строка":    "0x05",
	"Тип.Двоичный":  "0x06",
	"Тип.ВидСсылки": "0x07",
	"Тип.Ссылка":    "0x08",
}

func initConsts(m Metadata) {
	for k, v := range consts {
		m.Tables[k] = &Object{
			DBName: v,
			CVName: k,
		}
	}
}
