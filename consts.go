package sql1cv8

// Типы полей
var consts = map[string]string{
	"Тип.NULL":         "NULL",
	"Тип.Неопределено": "0x01",
	"Тип.Булево":       "0x02",
	"Тип.Число":        "0x03",
	"Тип.Дата":         "0x04",
	"Тип.Строка":       "0x05",
	"Тип.Двоичный":     "0x06",
	"Тип.Ссылка":       "0x08",
}

func initConsts(m Metadata) {
	for k, v := range consts {
		m.Tables[k] = &Object{
			DBName: v,
			CVName: k,
		}
	}
}

// Стандартные поля
var fields = map[string]string{
	"_Active":       "Активность",
	"_Code":         "Код",
	"_Date_Time":    "Дата",
	"_Description":  "Наименование",
	"_DimHash":      "ХэшИзмерений",
	"_EnumOrder":    "Порядок",
	"_Folder":       "Группа",
	"_IDRRef":       "Ссылка",
	"_KeyField":     "КлючЗаписи",
	"_LineNo":       "НомерСтроки",
	"_Marked":       "ПометкаУдаления",
	"_Number":       "Номер",
	"_NumberPrefix": "Префикс",
	"_OwnerID":      "Владелец",
	"_ParentIDRRef": "Родитель",
	"_Period":       "Период",
	"_Posted":       "Проведен",
	"_PredefinedID": "Предопределенное",
	"_RecorderRRef": "Регистратор",
	"_RecorderTRef": "ВидРегистратора",
	"_RecordKey":    "КлючЗаписи",
	"_RecordKind":   "ВидДвижения",
	"_Splitter":     "Разделитель",
	"_Type":         "ТипЗначения",
	"_Version":      "Версия",
}
