# sql1cv8

[![tag](https://img.shields.io/github/v/tag/mopo3ilo/sql1cv8?sort=semver)](tags)
[![go version](https://img.shields.io/github/go-mod/go-version/mopo3ilo/sql1cv8?label=go%20version)](https://go.dev/dl)
[![godoc](https://img.shields.io/badge/godoc-reference-blue.svg)](https://pkg.go.dev/github.com/mopo3ilo/sql1cv8)
[![go report](https://goreportcard.com/badge/github.com/mopo3ilo/sql1cv8)](https://goreportcard.com/report/github.com/mopo3ilo/sql1cv8)
[![build](https://img.shields.io/github/workflow/status/mopo3ilo/sql1cv8/test%20module)](actions/workflows/test.yml)
[![codecov](https://img.shields.io/codecov/c/github/mopo3ilo/sql1cv8)](https://codecov.io/gh/mopo3ilo/sql1cv8)

## Описание

Модуль для преобразования метаданных 1Cv8 в объекты базы данных в запросах.

Получение сопоставления метаданных и объектов базы данных берётся напрямую из базы из служебных таблиц. Работает только с базами данных SQL Server.

Для работы с базой данных используется драйвер от [denisenkom](https://github.com/denisenkom/go-mssqldb), так что смотрите [Connection Parameters and DSN](https://github.com/denisenkom/go-mssqldb#connection-parameters-and-dsn) для правильного написания строки подключения.

Для написания использовалась официальная документация:
- [Размещение данных 1С:Предприятия 8. Таблицы и поля](https://its.1c.ru/db/metod8dev/content/1798/hdoc)
- [Особенности хранения составных типов данных](https://its.1c.ru/db/metod8dev/content/1828/hdoc)

## Установка

Ничем не отличается от установки других модулей
```shell
go get -u github.com/mopo3ilo/sql1cv8
```

## Использование

### Описание модуля

Модуль экспортирует достаточно мало типов и методов. Их описание можно посмотреть как в самом коде, так и на [pkg.go.dev](https://pkg.go.dev/github.com/mopo3ilo/sql1cv8)

Могу дать только одну рекомендацию: желательно использовать метод **LoadNewer** вместо **LoadFromDB**, т.к. загрузка метаданных из базы затратна. Рекомендуемый метод сравнивает версию метаданных в файле и в базе данных, и обновляет файл только в том случае, если объекты были изменены.

### Пример работы с модулем

```go
package main

import (
  "fmt"
  "github.com/mopo3ilo/sql1cv8"
)

const (
  connectionString string = "sqlserver://..."
  metadataFileName string = "metadata.json"
)

var srcQuery string = `
SELECT items.[$Ссылка] AS item_id
      ,items.[$Код] AS item_code
      ,items.[$Наименование] AS item_descr
FROM [$Справочник.Номенклатура] AS items
WHERE items.[$ПометкаУдаления] = 0
`

func main() {
  m, err := sql1cv8.LoadNewer(connectionString, metadataFileName)
  if err != nil {
    panic(err)
  }
  fmt.Printf("Версия метаданных: %s\n", m.Version)

  qry, err := m.Parse(srcQuery)
  if err != nil {
    panic(err)
  }
  fmt.Println("Результат:\n%s", qry)
}
```

### Поддерживаемые объекты метаданных

Стандартные объекты:
- Константа.*ИмяКонстанты*
  - КлючЗаписи
  - *ИмяПараметра*
- Перечисление.*ИмяПеречисления*
  - Порядок
  - Ссылка
- ПланВидовХарактеристик.*ИмяПланаВидовХарактеристик*
  - Ссылка
  - Родитель
  - Владелец
  - Предопределенное
  - Версия
  - ПометкаУдаления
  - Группа
  - Код
  - Наименование
  - ТипЗначения
  - *ИмяПараметра*
- Справочник.*ИмяСправочника*
  - Ссылка
  - Родитель
  - Владелец
  - Предопределенное
  - Версия
  - ПометкаУдаления
  - Группа
  - Код
  - Наименование
  - *ИмяПараметра*
- Документ.*ИмяДокумента*
  - Ссылка
  - Версия
  - ПометкаУдаления
  - Проведен
  - Дата
  - Префикс
  - Номер
  - *ИмяПараметра*
- РегистрСведений.*ИмяРегистраСведений*
  - Период
  - Регистратор
  - ВидРегистратора
  - Активность
  - НомерСтроки
  - *ИмяПараметра*
- РегистрСведений.*ИмяРегистраСведений*.ИтогиСрезПоследних
  - Период
  - Регистратор
  - ВидРегистратора
  - *ИмяПараметра*
- РегистрСведений.*ИмяРегистраСведений*.ИтогиСрезПервых
  - Период
  - Регистратор
  - ВидРегистратора
  - *ИмяПараметра*
- РегистрНакопления.*ИмяРегистраНакопления*
  - Период
  - Регистратор
  - ВидРегистратора
  - Активность
  - НомерСтроки
  - ВидДвижения
  - ХэшИзмерений
  - *ИмяПараметра*
- РегистрНакопления.*ИмяРегистраНакопления*.Остатки
  - Период
  - Разделитель
  - ХэшИзмерений
  - *ИмяПараметра*
- РегистрНакопления.*ИмяРегистраНакопления*.Обороты
  - Период
  - Разделитель
  - ХэшИзмерений
  - *ИмяПараметра*

Если какой-то объект имеет табличную часть, то для доступа к ней следует добавить суффикс:
- *ОбъектМетаданных*.ТабличнаяЧасть.*ИмяТабличнойЧасти*
  - Ссылка
  - КлючЗаписи
  - НомерСтроки
  - *ИмяПараметра*

У перечисления поле "Порядок" по сути является порядковым номером значения этого перечисления, модуль может возвращать это число из объекта вида:
- Перечисление.*ИмяПеречисления*.*ИмяЗначения*

Например в регистрах или составных типах нередко указывается вид ссылки, который ссылается на какой-то обект метаданных по сути является бинарным значением, модуль так же может возвращать это значение из объекта вида:
- *ОбъектМетаданных*.ВидСсылки

Если какой-то параметр имеет составной тип, то к параметру следует добавлять суффикс:
- *ИмяПараметра*.Тип
- *ИмяПараметра*.Булево
- *ИмяПараметра*.Число
- *ИмяПараметра*.Дата
- *ИмяПараметра*.Строка
- *ИмяПараметра*.Двоичный
- *ИмяПараметра*.ВидСсылки
- *ИмяПараметра*.Ссылка

Список типов полей:
- Тип.NULL
- Тип.Неопределено
- Тип.Булево
- Тип.Число
- Тип.Дата
- Тип.Строка
- Тип.Двоичный
- Тип.Ссылка

Все объекты, которые должны быть обработаны должны быть заключены в конструкцию **[$...]**. Смотрите примеры, чтобы стало понятнее.

### Примеры написания запросов

Модуль понимает алиасы для таблиц, поэтому оба следующих запроса будут работать корректно.
```sql
SELECT [$Справочник.Номенклатура].[$Ссылка]
      ,[$Справочник.Номенклатура].[$Код]
      ,[$Справочник.Номенклатура].[$Наименование]
FROM [$Справочник.Номенклатура]

SELECT items.[$Ссылка]
      ,items.[$Код]
      ,items.[$Наименование]
FROM [$Справочник.Номенклатура] AS items
```

Однако модулю обязательно нужно указывать, к какому объекту метаданных относится параметр, в противном случае он не сможет его распознать. Например в следующем запросе параметры не распознаются.
```sql
SELECT [$Ссылка]
      ,[$Код]
      ,[$Наименование]
FROM [$Справочник.Номенклатура]
```

В данном примере показывается как можно использовать перечисления.
```sql
SELECT items.[$Ссылка] AS item_id
      ,items.[$Код] AS item_code
      ,items.[$Наименование] AS item_descr
      ,CASE item_types.[$Порядок]
        WHEN [$Перечисление.ОсобенностиУчетаНоменклатуры.БезОсобенностейУчета] THEN 'Без особенностей учета'
        WHEN [$Перечисление.ОсобенностиУчетаНоменклатуры.АлкогольнаяПродукция] THEN 'Алгольная (спиртосодежащая) продукция'
        WHEN [$Перечисление.ОсобенностиУчетаНоменклатуры.СодержитДрагоценныеМатериалы] THEN 'Содержит драгоценные металлы или камни'
        WHEN [$Перечисление.ОсобенностиУчетаНоменклатуры.ПродукцияМаркируемаяДляГИСМ] THEN 'Продукция, маркируемая для ГИСМ'
        WHEN [$Перечисление.ОсобенностиУчетаНоменклатуры.КиЗГИСМ] THEN 'Контрольный (идентификационный) знак (КиЗ) ГИСМ'
        ELSE ''
      END AS item_type
FROM [$Справочник.Номенклатура] AS items
JOIN [$Перечисление.ОсобенностиУчетаНоменклатуры] AS item_types
  ON items.[$ОсобенностьУчета] = item_types.[$Ссылка]
```

Теперь получим список реализованного за период. Намеренно использую вложенный запрос из предыдущего примера, чтобы показать, что они тоже нормально распознаются модулем.
```sql
DECLARE @offset INT
SELECT TOP 1 @offset = -Offset FROM _YearOffset

SELECT DATEADD(YEAR, @offset, headers.[$Дата]) AS doc_date
      ,headers.[$Номер] AS doc_no
      ,items.item_code
      ,items.item_descr
      ,items.item_type
      ,lines.[$Количество] AS quantity
      ,lines.[$Сумма] AS amount
FROM [$Документ.РеализацияТоваровУслуг] AS headers
JOIN [$Документ.РеализацияТоваровУслуг.ТабличнаяЧасть.Товары] AS lines
  ON headers.[$Ссылка] = lines.[$Ссылка]
JOIN (
  SELECT items.[$Ссылка] AS item_id
        ,items.[$Код] AS item_code
        ,items.[$Наименование] AS item_descr
        ,CASE item_types.[$Порядок]
          WHEN [$Перечисление.ОсобенностиУчетаНоменклатуры.БезОсобенностейУчета] THEN 'Без особенностей учета'
          WHEN [$Перечисление.ОсобенностиУчетаНоменклатуры.АлкогольнаяПродукция] THEN 'Алгольная (спиртосодежащая) продукция'
          WHEN [$Перечисление.ОсобенностиУчетаНоменклатуры.СодержитДрагоценныеМатериалы] THEN 'Содержит драгоценные металлы или камни'
          WHEN [$Перечисление.ОсобенностиУчетаНоменклатуры.ПродукцияМаркируемаяДляГИСМ] THEN 'Продукция, маркируемая для ГИСМ'
          WHEN [$Перечисление.ОсобенностиУчетаНоменклатуры.КиЗГИСМ] THEN 'Контрольный (идентификационный) знак (КиЗ) ГИСМ'
          ELSE ''
        END AS item_type
  FROM [$Справочник.Номенклатура] AS items
  JOIN [$Перечисление.ОсобенностиУчетаНоменклатуры] AS item_types
    ON items.[$ОсобенностьУчета] = item_types.[$Ссылка]
) AS items
  ON lines.[$Номенклатура] = items.item_id
WHERE DATEADD(YEAR, @offset, headers.[$Дата]) BETWEEN '2021-01-01' AND '2022-01-01'
  AND headers.[$Проведен] = 1
```

В данном примере мы получим список реализованного товара из регистра в котором можно увидеть использование вида ссылки.
```sql
DECLARE @offset INT
SELECT TOP 1 @offset = -Offset FROM _YearOffset

SELECT DATEADD(YEAR, @offset, reg.[$Период]) AS period
      ,headers.[$Номер] AS doc_no
      ,items.[$Код] AS item_code
      ,items.[$Наименование] AS item_descr
      ,CASE reg.[$ВидДвижения]
        WHEN 0
        THEN reg.[$ВНаличии]
        ELSE -reg.[$ВНаличии]
      END AS quantity
FROM [$РегистрНакопления.ТоварыНаСкладах] AS reg
JOIN [$Документ.РеализацияТоваровУслуг] AS doc
  ON reg.[$Регистратор] = doc.[$Ссылка]
  AND reg.[$ВидРегистратора] = [$Документ.РеализацияТоваровУслуг.ВидСсылки]
JOIN [$Справочник.Номенклатура] AS items
  ON reg.[$Номенклатура] = items.[$Ссылка]
WHERE DATEADD(YEAR, @offset, reg.[$Период]) BETWEEN '2021-01-01' AND '2021-12-31'
```

Следующий пример демострирует работу с составными типами. Объекты выдуманны, лень было искать в конфигурации.
```sql
DECLARE @offset INT
SELECT TOP 1 @offset = -Offset FROM _YearOffset

SELECT items.[$Код] AS item_code
      ,items.[$Наименование] AS item_descr
      ,CASE items.[$Источник.Тип]
        WHEN [$Тип.Ссылка] THEN doc.[$Номер] + ' от ' + CONVERT(NVARCHAR(10), DATEADD(YEAR, @offset, doc[$Дата]), 104)
        WHEN [$Тип.Строка] THEN items.[$Источник.Строка]
        ELSE ''
      END AS source
FROM [$Справочник.Номенклатура] AS items
LEFT JOIN [$Документ.ЗагрузкаНоменклатуры] AS doc
  ON items.[$Источник.Ссылка] = doc.[$Ссылка]
  AND items.[$Источник.ВидСсылки] = [$Документ.ЗагрузкаНоменклатуры.ВидСсылки]
WHERE items.[$Группа] = 1
  AND items.[$ПометкаУдаления] = 0
```
