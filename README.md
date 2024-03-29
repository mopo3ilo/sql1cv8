# sql1cv8

[![tag](https://img.shields.io/github/v/tag/mopo3ilo/sql1cv8?sort=semver)](https://github.com/mopo3ilo/sql1cv8/tags)
[![go version](https://img.shields.io/github/go-mod/go-version/mopo3ilo/sql1cv8?label=go%20version)](https://go.dev/dl)
[![godoc](https://img.shields.io/badge/godoc-reference-blue.svg)](https://pkg.go.dev/github.com/mopo3ilo/sql1cv8)
[![go report](https://goreportcard.com/badge/github.com/mopo3ilo/sql1cv8)](https://goreportcard.com/report/github.com/mopo3ilo/sql1cv8)
[![build](https://img.shields.io/github/actions/workflow/status/mopo3ilo/sql1cv8/test%20module)](https://github.com/mopo3ilo/sql1cv8/actions)
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
Все объекты объекты метаданных должны быть заключены в конструкцию **[$...]**. Смотрите примеры, чтобы стало понятнее.

### Поддерживаемые объекты метаданных

Стандартные объекты:
- Константа.*ИмяКонстанты*
  - КлючЗаписи
  - *ИмяПараметра*
- Перечисление.*ИмяПеречисления*
  - Ссылка
  - Порядок
- Перечисление.*ИмяПеречисления*.*ИмяЗначения*
- ПланОбмена.*ИмяПланаОбмена*
  - Ссылка
  - Версия
  - ПометкаУдаления
  - Предопределенное
  - Код
  - Наименование
  - НомерОтправленного
  - НомерПринятого
  - *ИмяПараметра*
- ПланОбмена.*ИмяПланаОбмена*.ТабличнаяЧасть.*ИмяТабличнойЧасти*
  - Ссылка
  - КлючЗаписи
  - НомерСтроки
  - *ИмяПараметра*
- Задача.*ИмяЗадачи*
  - Ссылка
  - Версия
  - ПометкаУдаления
  - БизнесПроцесс
  - ТочкаМаршрута
  - Дата
  - Номер
  - Наименование
  - Выполнена
  - *ИмяПараметра*
- Задача.*ИмяЗадачи*.ТабличнаяЧасть.*ИмяТабличнойЧасти*
  - Ссылка
  - КлючЗаписи
  - НомерСтроки
  - *ИмяПараметра*
- БизнесПроцесс.*ИмяБизнесПроцесса*
  - Ссылка
  - Версия
  - ПометкаУдаления
  - Дата
  - Завершен
  - Номер
  - ВедущаяЗадача
  - Стартован
  - *ИмяПараметра*
- БизнесПроцесс.*ИмяБизнесПроцесса*.ТабличнаяЧасть.*ИмяТабличнойЧасти*
  - Ссылка
  - КлючЗаписи
  - НомерСтроки
  - *ИмяПараметра*
- БизнесПроцесс.*ИмяБизнесПроцесса*.ТочкиМаршрута
  - Ссылка
  - Порядок
- БизнесПроцесс.*ИмяБизнесПроцесса*.ТочкиМаршрута.*ИмяТочкиМаршрута*
- ПланВидовХарактеристик.*ИмяПланаВидовХарактеристик*
  - Ссылка
  - Версия
  - ПометкаУдаления
  - Предопределенное
  - Родитель
  - Владелец
  - ЭтоГруппа
  - Код
  - Наименование
  - ТипЗначения
  - *ИмяПараметра*
- ПланВидовХарактеристик.*ИмяПланаВидовХарактеристик*.ТабличнаяЧасть.*ИмяТабличнойЧасти*
  - Ссылка
  - КлючЗаписи
  - НомерСтроки
  - *ИмяПараметра*
- Справочник.*ИмяСправочника*
  - Ссылка
  - Версия
  - ПометкаУдаления
  - Предопределенное
  - Родитель
  - Владелец
  - ЭтоГруппа
  - Код
  - Наименование
  - *ИмяПараметра*
- Справочник.*ИмяСправочника*.ТабличнаяЧасть.*ИмяТабличнойЧасти*
  - Ссылка
  - КлючЗаписи
  - НомерСтроки
  - *ИмяПараметра*
- Документ.*ИмяДокумента*
  - Ссылка
  - Версия
  - ПометкаУдаления
  - Дата
  - Префикс
  - Номер
  - Проведен
  - *ИмяПараметра*
- Документ.*ИмяДокумента*.ТабличнаяЧасть.*ИмяТабличнойЧасти*
  - Ссылка
  - КлючЗаписи
  - НомерСтроки
  - *ИмяПараметра*
- ЖурналДокументов.*ИмяЖурналаДокументов*
  - Документ
  - ВидДокумента
  - ПометкаУдаления
  - Дата
  - Номер
  - Проведен
  - *ИмяПараметра*
- РегистрСведений.*ИмяРегистраСведений*
  - Период
  - Регистратор
  - ВидРегистратора
  - НомерСтроки
  - Активность
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
  - НомерСтроки
  - Активность
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
- ПланСчетов.*ИмяПланаСчетов*
  - Ссылка
  - Версия
  - ПометкаУдаления
  - Предопределенное
  - Родитель
  - Код
  - Наименование
  - Порядок
  - Вид
  - Забалансовый
  - *ИмяПараметра*
- ПланСчетов.*ИмяПланаСчетов*.ВидыСубконто
  - Ссылка
  - КлючЗаписи
  - НомерСтроки
  - ВидСубконто
  - Предопределенное
  - ТолькоОбороты
  - *ИмяПараметра*
- ПланСчетов.*ИмяПланаСчетов*.ТабличнаяЧасть.*ИмяТабличнойЧасти*
  - Ссылка
  - КлючЗаписи
  - НомерСтроки
  - *ИмяПараметра*
- РегистрБухгалтерии.*ИмяРегистраБухгалтерии*
  - Период
  - УточнениеПериода
  - Регистратор
  - ВидРегистратора
  - НомерСтроки
  - Активность
  - Счет
  - СчетДт
  - СчетКт
  - ВидДвижения
  - Субконто*1..N*
  - ВидСубконто*1..N*
  - СубконтоДт*1..N*
  - ВидСубконтоДт*1..N*
  - СубконтоКт*1..N*
  - ВидСубконтоКт*1..N*
  - ХэшПроводки
  - ХэшПроводкиДт
  - ХэшПроводкиКт
  - *ИмяПараметра*
- РегистрБухгалтерии.*ИмяРегистраБухгалтерии*.ЗначенияСубконто
  - Период
  - УточнениеПериода
  - Регистратор
  - ВидРегистратора
  - НомерСтроки
  - ВидДвижения
  - Вид
  - Значение
  - *ИмяПараметра*
- РегистрБухгалтерии.*ИмяРегистраБухгалтерии*.ИтогиМеждуСчетами
  - Период
  - Счет
  - СчетДт
  - СчетКт
  - Разделитель
  - *ИмяПараметра*
  - *ИмяПараметра*Дт
  - *ИмяПараметра*Кт
- РегистрБухгалтерии.*ИмяРегистраБухгалтерии*.ИтогиПоСчетам
  - Период
  - Счет
  - Разделитель
  - *ИмяПараметра*
  - *Сумма*
  - *Сумма*Дт
  - *Сумма*Кт
- РегистрБухгалтерии.*ИмяРегистраБухгалтерии*.ИтогиПоСчетамССубконто*N*
  - Период
  - Счет
  - Разделитель
  - Субконто*1..N*
  - *ИмяПараметра*
  - *Сумма*
  - *Сумма*Дт
  - *Сумма*Кт
- ПланВидовРасчета.*ИмяПланаВидовРасчета*
  - Ссылка
  - Версия
  - ПометкаУдаления
  - Предопределенное
  - Код
  - Наименование
  - ПериодДействияБазовый
  - *ИмяПараметра*
- ПланВидовРасчета.*ИмяПланаВидовРасчета*.ВедущиеВидыРасчета
  - Ссылка
  - КлючЗаписи
  - НомерСтроки
  - ВидРасчета
  - *ИмяПараметра*
- ПланВидовРасчета.*ИмяПланаВидовРасчета*.БазовыеВидыРасчета
  - Ссылка
  - КлючЗаписи
  - НомерСтроки
  - ВидРасчета
  - *ИмяПараметра*
- ПланВидовРасчета.*ИмяПланаВидовРасчета*.ВытесняющиеВидыРасчета
  - Ссылка
  - КлючЗаписи
  - НомерСтроки
  - ВидРасчета
  - *ИмяПараметра*
- ПланВидовРасчета.*ИмяПланаВидовРасчета*.ТабличнаяЧасть.*ИмяТабличнойЧасти*
  - Ссылка
  - КлючЗаписи
  - НомерСтроки
  - *ИмяПараметра*

У перечисления и точки маршрута поле "Порядок" является порядковым номером значения, модуль может возвращать это число из объекта вида:
- Перечисление.*ИмяПеречисления*.*ИмяЗначения*
- БизнесПроцесс.*ИмяБизнесПроцесса*.ТочкиМаршрута.*ИмяТочкиМаршрута*

В регистрах или составных типах нередко указывается вид ссылки, который ссылается на какой-то обект метаданных по сути является бинарным значением, модуль так же может возвращать это значение из объекта вида:
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

В модуль добавлено несколько витуальных объектов (скоращения) для облегчения написания запросов. Они обрамляются конструкцией **[$$...]**, с двойным символом доллара.
Для перечислений и точек маршрута это подзапросы. Первый возвращает таблицу в которой Код - имя значения в конфигураторе, Наименование - синоним значения. Второй возвращает не "Порядок", а "Ссылку" на значение.
- Перечисление.*ИмяПеречисления*
  - Ссылка
  - Код
  - Наименование
- Перечисление.*ИмяПеречисления*.*ИмяЗначения*
- БизнесПроцесс.*ИмяБизнесПроцесса*.ТочкиМаршрута
  - Ссылка
  - Код
  - Наименование
- БизнесПроцесс.*ИмяБизнесПроцесса*.ТочкиМаршрута.*ИмяТочкиМаршрута*

```sql
/*
select
  t.[$Ссылка],
  t.[$Код],
  t.[$Наименование]
from [$$Перечисление.ФормыОплаты] t
*/
select
  t._IDRRef,
  t._Code,
  t._Description
from (select _IDRRef, case _EnumOrder when 0 then 'Наличная' when 1 then 'Безналичная' ... end _Code, case when 0 then 'Наличная' when 1 then 'Безналичная' ... end _Description from _Enum1273) t
-- [$$Перечисление.ФормыОплаты.Наличная]
(select top 1 _IDRRef from _Enum1273 where _EnumOrder = 0)
/*
select
  t.[$Ссылка],
  t.[$Код],
  t.[$Наименование]
from [$$БизнесПроцесс.Задание.ТочкиМаршрута] t
*/
select
  t._IDRRef,
  t._Code,
  t._Description
from (select _IDRRef, case _RoutePointOrder when 1 then 'Старт' when 3 then 'Выполнить' ... end _Code, case when 1 then '' when 3 then 'Выполнить' ... end _Description from _BPrPoints1298) t
-- [$$БизнесПроцесс.Задание.ТочкиМаршрута.Выполнить]
(select top 1 _IDRRef from _BPrPoints1298 where _RoutePointOrder = 3)
```

В модуль добавлены функции, которые возвращают внутренние занчения объектов:
- UUID
- Type
- Number
- DBName

Пример работы можно видеть в запросе.

```sql
/*
select
  [$Справочник.Организации].UUID,
  [$Справочник.Организации].[$Код].UUID,
  [$Справочник.Организации].[$Наименование].UUID,
  [$Справочник.Организации].[$ИНН].UUID
*/
select
  'fd0c3124-91f5-4c1e-bbc0-f2163e61ff2a',
  '',
  '',
  '1d8f020e-088f-45bb-996b-211e297d3c4e'

/*
select
  [$Справочник.Организации].Type,
  [$Справочник.Организации].[$Код].Type,
  [$Справочник.Организации].[$Наименование].Type,
  [$Справочник.Организации].[$ИНН].Type
*/
select
  'Reference',
  'Code',
  'Description',
  'Fld'

/*
select
  [$Справочник.Организации].Number,
  [$Справочник.Организации].[$Код].Number,
  [$Справочник.Организации].[$Наименование].Number,
  [$Справочник.Организации].[$ИНН].Number

NOTE:
  Обратите внимание, что у предопределённых полей
  возращается не номер, а имя поля,
  при том оно не выделено кавычками.
  Баг это или фича, решать вам.
*/
select
  99,
  _Code,
  _Description,
  12934

/*
select
  [$Справочник.Организации].DBName,
  [$Справочник.Организации].[$Код].DBName,
  [$Справочник.Организации].[$Наименование].DBName,
  [$Справочник.Организации].[$ИНН].DBName
*/
select
  '_Reference99',
  '_Code',
  '_Description',
  '_Fld12934'
```

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

Теперь получим список реализованного за период. Намерено использую вложенный запрос из предыдущего примера, чтобы показать, что они тоже нормально распознаются модулем.
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

Следующий пример демонстрирует работу с составными типами. Объекты выдуманы, лень было искать в конфигурации.
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
WHERE items.[$ЭтоГруппа] = 1
  AND items.[$ПометкаУдаления] = 0
```
