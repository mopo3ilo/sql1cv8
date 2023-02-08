select
  DataType,
  TableName,
  FieldName,
  TablePrefix,
  TableNumber,
  TableSuffix,
  VTPrefix,
  VTNumber,
  VTSuffix,
  FieldPrefix,
  FieldNumber,
  FieldSuffix
from (
  select
    DataType,
    TableName,
    FieldName,
    TablePrefix,
    TableNumber,
    TableSuffix,
    VTPrefix,
    VTNumber,
    VTSuffix,
    FieldPrefix,
    FieldNumber,
    FieldSuffix,
    DN = dense_rank() over(partition by TablePrefix, TableNumber, TableSuffix, VTPrefix, VTNumber, VTSuffix order by TableName desc)
  from (
    -- Константа
    select DataType     = 'Const'
          ,TableName    = t.name
          ,FieldName    = c.name
          ,TablePrefix  = 'Константа.'
          ,TableNumber  = substring(t.name, 7, patindex('%[^0-9]%', substring(t.name, 7, 10) + '.') - 1)
          ,TableSuffix  = ''
          ,VTPrefix     = ''
          ,VTNumber     = ''
          ,VTSuffix     = ''
          ,FieldPrefix  = ''
          ,FieldNumber  = case
            when left(c.name, 4) = '_Fld' then substring(c.name, 5, patindex('%[^0-9]%', substring(c.name, 5, 10) + '.') - 1)
            else c.name
          end
          ,FieldSuffix  = case
            when right(c.name, 5) = '_TYPE' then '.Тип'
            when right(c.name, 2) = '_L' then '.Булево'
            when right(c.name, 2) = '_N' then '.Число'
            when right(c.name, 2) = '_T' then '.Дата'
            when right(c.name, 2) = '_S' then '.Строка'
            when right(c.name, 2) = '_B' then '.Двоичный'
            when right(c.name, 6) = '_RTRef' then '.ВидСсылки'
            when right(c.name, 6) = '_RRRef' then '.Ссылка'
            else ''
          end
    from sys.tables t
        ,sys.columns c
    where t.object_id = c.object_id
      and t.name like '[_]Const[0-9]%'
      and t.name not like '%[_]VT[0-9]%'
    union all

    -- Перечисление
    select DataType     = 'Enum'
          ,TableName    = t.name
          ,FieldName    = c.name
          ,TablePrefix  = 'Перечисление.'
          ,TableNumber  = substring(t.name, 6, patindex('%[^0-9]%', substring(t.name, 6, 10) + '.') - 1)
          ,TableSuffix  = ''
          ,VTPrefix     = ''
          ,VTNumber     = ''
          ,VTSuffix     = ''
          ,FieldPrefix  = ''
          ,FieldNumber  = c.name
          ,FieldSuffix  = ''
    from sys.tables t
        ,sys.columns c
    where t.object_id = c.object_id
      and t.name like '[_]Enum[0-9]%'
      and t.name not like '%[_]VT[0-9]%'
    union all

    -- ПланОбмена
    select DataType     = 'Node'
          ,TableName    = t.name
          ,FieldName    = c.name
          ,TablePrefix  = 'ПланОбмена.'
          ,TableNumber  = substring(t.name, 6, patindex('%[^0-9]%', substring(t.name, 6, 10) + '.') - 1)
          ,TableSuffix  = ''
          ,VTPrefix     = ''
          ,VTNumber     = ''
          ,VTSuffix     = ''
          ,FieldPrefix  = ''
          ,FieldNumber  = case
            when left(c.name, 4) = '_Fld' then substring(c.name, 5, patindex('%[^0-9]%', substring(c.name, 5, 10) + '.') - 1)
            else c.name
          end
          ,FieldSuffix  = case
            when right(c.name, 5) = '_TYPE' then '.Тип'
            when right(c.name, 2) = '_L' then '.Булево'
            when right(c.name, 2) = '_N' then '.Число'
            when right(c.name, 2) = '_T' then '.Дата'
            when right(c.name, 2) = '_S' then '.Строка'
            when right(c.name, 2) = '_B' then '.Двоичный'
            when right(c.name, 6) = '_RTRef' then '.ВидСсылки'
            when right(c.name, 6) = '_RRRef' then '.Ссылка'
            else ''
          end
    from sys.tables t
        ,sys.columns c
    where t.object_id = c.object_id
      and t.name like '[_]Node[0-9]%'
      and t.name not like '%[_]VT[0-9]%'
    union all

    -- ПланОбмена.ТабличнаяЧасть
    select DataType     = 'VT'
          ,TableName    = t.name
          ,FieldName    = c.name
          ,TablePrefix  = 'ПланОбмена.'
          ,TableNumber  = substring(t.name, 6, patindex('%[^0-9]%', substring(t.name, 6, 10) + '.') - 1)
          ,TableSuffix  = ''
          ,VTPrefix     = '.ТабличнаяЧасть.'
          ,VTNumber     = substring(t.name, charindex('_VT', t.name) + 3, patindex('%[^0-9]%', substring(t.name, charindex('_VT', t.name) + 3, 10) + '.') - 1)
          ,VTSuffix     = ''
          ,FieldPrefix  = ''
          ,FieldNumber  = case
            when left(c.name, 4) = '_Fld' then substring(c.name, 5, patindex('%[^0-9]%', substring(c.name, 5, 10) + '.') - 1)
            when left(c.name, 5) = '_Node' and right(c.name, 7) = '_IDRRef' then right(c.name, 7)
            when left(c.name, 7) = '_LineNo' then left(c.name, 7)
            else c.name
          end
          ,FieldSuffix  = case
            when right(c.name, 5) = '_TYPE' then '.Тип'
            when right(c.name, 2) = '_L' then '.Булево'
            when right(c.name, 2) = '_N' then '.Число'
            when right(c.name, 2) = '_T' then '.Дата'
            when right(c.name, 2) = '_S' then '.Строка'
            when right(c.name, 2) = '_B' then '.Двоичный'
            when right(c.name, 6) = '_RTRef' then '.ВидСсылки'
            when right(c.name, 6) = '_RRRef' then '.Ссылка'
            else ''
          end
    from sys.tables t
        ,sys.columns c
    where t.object_id = c.object_id
      and t.name like '[_]Node[0-9]%[_]VT[0-9]%'
    union all

    -- БизнесПроцессы
    select DataType     = 'BPr'
          ,TableName    = t.name
          ,FieldName    = c.name
          ,TablePrefix  = 'БизнесПроцесс.'
          ,TableNumber  = substring(t.name, 5, patindex('%[^0-9]%', substring(t.name, 5, 10) + '.') - 1)
          ,TableSuffix  = ''
          ,VTPrefix     = ''
          ,VTNumber     = ''
          ,VTSuffix     = ''
          ,FieldPrefix  = ''
          ,FieldNumber  = case
            when left(c.name, 4) = '_Fld' then substring(c.name, 5, patindex('%[^0-9]%', substring(c.name, 5, 10) + '.') - 1)
            else c.name
          end
          ,FieldSuffix  = case
            when right(c.name, 5) = '_TYPE' then '.Тип'
            when right(c.name, 2) = '_L' then '.Булево'
            when right(c.name, 2) = '_N' then '.Число'
            when right(c.name, 2) = '_T' then '.Дата'
            when right(c.name, 2) = '_S' then '.Строка'
            when right(c.name, 2) = '_B' then '.Двоичный'
            when right(c.name, 6) = '_RTRef' then '.ВидСсылки'
            when right(c.name, 6) = '_RRRef' then '.Ссылка'
            else ''
          end
    from sys.tables t
        ,sys.columns c
    where t.object_id = c.object_id
      and t.name like '[_]BPr[0-9]%'
      and t.name not like '%[_]VT[0-9]%'
    union all

    -- БизнесПроцессы.ТочкиМаршрута
    select DataType     = 'BPrPoints'
          ,TableName    = t.name
          ,FieldName    = c.name
          ,TablePrefix  = 'БизнесПроцесс.'
          ,TableNumber  = substring(t.name, 11, patindex('%[^0-9]%', substring(t.name, 11, 10) + '.') - 1)
          ,TableSuffix  = '.ТочкиМаршрута'
          ,VTPrefix     = ''
          ,VTNumber     = ''
          ,VTSuffix     = ''
          ,FieldPrefix  = ''
          ,FieldNumber  = c.name
          ,FieldSuffix  = ''
    from sys.tables t
        ,sys.columns c
    where t.object_id = c.object_id
      and t.name like '[_]BPrPoints[0-9]%'
      and t.name not like '%[_]VT[0-9]%'
    union all

    -- БизнесПроцессы.ТабличнаяЧасть
    select DataType     = 'VT'
          ,TableName    = t.name
          ,FieldName    = c.name
          ,TablePrefix  = 'БизнесПроцесс.'
          ,TableNumber  = substring(t.name, 5, patindex('%[^0-9]%', substring(t.name, 5, 10) + '.') - 1)
          ,TableSuffix  = ''
          ,VTPrefix     = '.ТабличнаяЧасть.'
          ,VTNumber     = substring(t.name, charindex('_VT', t.name) + 3, patindex('%[^0-9]%', substring(t.name, charindex('_VT', t.name) + 3, 10) + '.') - 1)
          ,VTSuffix     = ''
          ,FieldPrefix  = ''
          ,FieldNumber  = case
            when left(c.name, 4) = '_Fld' then substring(c.name, 5, patindex('%[^0-9]%', substring(c.name, 5, 10) + '.') - 1)
            when left(c.name, 4) = '_BPr' and right(c.name, 7) = '_IDRRef' then right(c.name, 7)
            when left(c.name, 7) = '_LineNo' then left(c.name, 7)
            else c.name
          end
          ,FieldSuffix  = case
            when right(c.name, 5) = '_TYPE' then '.Тип'
            when right(c.name, 2) = '_L' then '.Булево'
            when right(c.name, 2) = '_N' then '.Число'
            when right(c.name, 2) = '_T' then '.Дата'
            when right(c.name, 2) = '_S' then '.Строка'
            when right(c.name, 2) = '_B' then '.Двоичный'
            when right(c.name, 6) = '_RTRef' then '.ВидСсылки'
            when right(c.name, 6) = '_RRRef' then '.Ссылка'
            else ''
          end
    from sys.tables t
        ,sys.columns c
    where t.object_id = c.object_id
      and t.name like '[_]BPr[0-9]%[_]VT[0-9]%'
    union all

    -- Задачи
    select DataType     = 'Task'
          ,TableName    = t.name
          ,FieldName    = c.name
          ,TablePrefix  = 'Задача.'
          ,TableNumber  = substring(t.name, 6, patindex('%[^0-9]%', substring(t.name, 6, 10) + '.') - 1)
          ,TableSuffix  = ''
          ,VTPrefix     = ''
          ,VTNumber     = ''
          ,VTSuffix     = ''
          ,FieldPrefix  = ''
          ,FieldNumber  = case
            when left(c.name, 4) = '_Fld' then substring(c.name, 5, patindex('%[^0-9]%', substring(c.name, 5, 10) + '.') - 1)
            when left(c.name, 16) = '_BusinessProcess' then left(c.name, 16)
            when left(c.name, 6) = '_Point' then left(c.name, 6)
            else c.name
          end
          ,FieldSuffix  = case
            when right(c.name, 5) = '_TYPE' then '.Тип'
            when right(c.name, 2) = '_L' then '.Булево'
            when right(c.name, 2) = '_N' then '.Число'
            when right(c.name, 2) = '_T' then '.Дата'
            when right(c.name, 2) = '_S' then '.Строка'
            when right(c.name, 2) = '_B' then '.Двоичный'
            when right(c.name, 6) = '_RTRef' then '.ВидСсылки'
            when right(c.name, 6) = '_RRRef' then '.Ссылка'
            else ''
          end
    from sys.tables t
        ,sys.columns c
    where t.object_id = c.object_id
      and t.name like '[_]Task[0-9]%'
      and t.name not like '%[_]VT[0-9]%'
    union all

    -- Задачи.ТабличнаяЧасть
    select DataType     = 'VT'
          ,TableName    = t.name
          ,FieldName    = c.name
          ,TablePrefix  = 'Задача.'
          ,TableNumber  = substring(t.name, 6, patindex('%[^0-9]%', substring(t.name, 6, 10) + '.') - 1)
          ,TableSuffix  = ''
          ,VTPrefix     = '.ТабличнаяЧасть.'
          ,VTNumber     = substring(t.name, charindex('_VT', t.name) + 3, patindex('%[^0-9]%', substring(t.name, charindex('_VT', t.name) + 3, 10) + '.') - 1)
          ,VTSuffix     = ''
          ,FieldPrefix  = ''
          ,FieldNumber  = case
            when left(c.name, 4) = '_Fld' then substring(c.name, 5, patindex('%[^0-9]%', substring(c.name, 5, 10) + '.') - 1)
            when left(c.name, 5) = '_Task' and right(c.name, 7) = '_IDRRef' then right(c.name, 7)
            when left(c.name, 7) = '_LineNo' then left(c.name, 7)
            else c.name
          end
          ,FieldSuffix  = case
            when right(c.name, 5) = '_TYPE' then '.Тип'
            when right(c.name, 2) = '_L' then '.Булево'
            when right(c.name, 2) = '_N' then '.Число'
            when right(c.name, 2) = '_T' then '.Дата'
            when right(c.name, 2) = '_S' then '.Строка'
            when right(c.name, 2) = '_B' then '.Двоичный'
            when right(c.name, 6) = '_RTRef' then '.ВидСсылки'
            when right(c.name, 6) = '_RRRef' then '.Ссылка'
            else ''
          end
    from sys.tables t
        ,sys.columns c
    where t.object_id = c.object_id
      and t.name like '[_]Task[0-9]%[_]VT[0-9]%'
    union all

    -- ПланВидовХарактеристик
    select DataType     = 'Chrc'
          ,TableName    = t.name
          ,FieldName    = c.name
          ,TablePrefix  = 'ПланВидовХарактеристик.'
          ,TableNumber  = substring(t.name, 6, patindex('%[^0-9]%', substring(t.name, 6, 10) + '.') - 1)
          ,TableSuffix  = ''
          ,VTPrefix     = ''
          ,VTNumber     = ''
          ,VTSuffix     = ''
          ,FieldPrefix  = ''
          ,FieldNumber  = case
            when left(c.name, 4) = '_Fld' then substring(c.name, 5, patindex('%[^0-9]%', substring(c.name, 5, 10) + '.') - 1)
            when left(c.name, 8) = '_OwnerID' then left(c.name, 8)
            else c.name
          end
          ,FieldSuffix  = case
            when right(c.name, 5) = '_TYPE' then '.Тип'
            when right(c.name, 2) = '_L' then '.Булево'
            when right(c.name, 2) = '_N' then '.Число'
            when right(c.name, 2) = '_T' then '.Дата'
            when right(c.name, 2) = '_S' then '.Строка'
            when right(c.name, 2) = '_B' then '.Двоичный'
            when right(c.name, 6) = '_RTRef' then '.ВидСсылки'
            when right(c.name, 6) = '_RRRef' then '.Ссылка'
            else ''
          end
    from sys.tables t
        ,sys.columns c
    where t.object_id = c.object_id
      and t.name like '[_]Chrc[0-9]%'
      and t.name not like '%[_]VT[0-9]%'
    union all

    -- ПланВидовХарактеристик.ТабличнаяЧасть
    select DataType     = 'VT'
          ,TableName    = t.name
          ,FieldName    = c.name
          ,TablePrefix  = 'ПланВидовХарактеристик.'
          ,TableNumber  = substring(t.name, 6, patindex('%[^0-9]%', substring(t.name, 6, 10) + '.') - 1)
          ,TableSuffix  = ''
          ,VTPrefix     = '.ТабличнаяЧасть.'
          ,VTNumber     = substring(t.name, charindex('_VT', t.name) + 3, patindex('%[^0-9]%', substring(t.name, charindex('_VT', t.name) + 3, 10) + '.') - 1)
          ,VTSuffix     = ''
          ,FieldPrefix  = ''
          ,FieldNumber  = case
            when left(c.name, 4) = '_Fld' then substring(c.name, 5, patindex('%[^0-9]%', substring(c.name, 5, 10) + '.') - 1)
            when left(c.name, 5) = '_Chrc' and right(c.name, 7) = '_IDRRef' then right(c.name, 7)
            when left(c.name, 7) = '_LineNo' then left(c.name, 7)
            else c.name
          end
          ,FieldSuffix  = case
            when right(c.name, 5) = '_TYPE' then '.Тип'
            when right(c.name, 2) = '_L' then '.Булево'
            when right(c.name, 2) = '_N' then '.Число'
            when right(c.name, 2) = '_T' then '.Дата'
            when right(c.name, 2) = '_S' then '.Строка'
            when right(c.name, 2) = '_B' then '.Двоичный'
            when right(c.name, 6) = '_RTRef' then '.ВидСсылки'
            when right(c.name, 6) = '_RRRef' then '.Ссылка'
            else ''
          end
    from sys.tables t
        ,sys.columns c
    where t.object_id = c.object_id
      and t.name like '[_]Chrc[0-9]%[_]VT[0-9]%'
    union all

    -- Справочник
    select DataType     = 'Reference'
          ,TableName    = t.name
          ,FieldName    = c.name
          ,TablePrefix  = 'Справочник.'
          ,TableNumber  = substring(t.name, 11, patindex('%[^0-9]%', substring(t.name, 11, 10) + '.') - 1)
          ,TableSuffix  = ''
          ,VTPrefix     = ''
          ,VTNumber     = ''
          ,VTSuffix     = ''
          ,FieldPrefix  = ''
          ,FieldNumber  = case
            when left(c.name, 4) = '_Fld' then substring(c.name, 5, patindex('%[^0-9]%', substring(c.name, 5, 10) + '.') - 1)
            when left(c.name, 8) = '_OwnerID' then left(c.name, 8)
            else c.name
          end
          ,FieldSuffix  = case
            when right(c.name, 5) = '_TYPE' then '.Тип'
            when right(c.name, 2) = '_L' then '.Булево'
            when right(c.name, 2) = '_N' then '.Число'
            when right(c.name, 2) = '_T' then '.Дата'
            when right(c.name, 2) = '_S' then '.Строка'
            when right(c.name, 2) = '_B' then '.Двоичный'
            when right(c.name, 6) = '_RTRef' then '.ВидСсылки'
            when right(c.name, 6) = '_RRRef' then '.Ссылка'
            else ''
          end
    from sys.tables t
        ,sys.columns c
    where t.object_id = c.object_id
      and t.name like '[_]Reference[0-9]%'
      and t.name not like '%[_]VT[0-9]%'
    union all

    -- Справочник.ТабличнаяЧасть
    select DataType     = 'VT'
          ,TableName    = t.name
          ,FieldName    = c.name
          ,TablePrefix  = 'Справочник.'
          ,TableNumber  = substring(t.name, 11, patindex('%[^0-9]%', substring(t.name, 11, 10) + '.') - 1)
          ,TableSuffix  = ''
          ,VTPrefix     = '.ТабличнаяЧасть.'
          ,VTNumber     = substring(t.name, charindex('_VT', t.name) + 3, patindex('%[^0-9]%', substring(t.name, charindex('_VT', t.name) + 3, 10) + '.') - 1)
          ,VTSuffix     = ''
          ,FieldPrefix  = ''
          ,FieldNumber  = case
            when left(c.name, 4) = '_Fld' then substring(c.name, 5, patindex('%[^0-9]%', substring(c.name, 5, 10) + '.') - 1)
            when left(c.name, 10) = '_Reference' and right(c.name, 7) = '_IDRRef' then right(c.name, 7)
            when left(c.name, 7) = '_LineNo' then left(c.name, 7)
            else c.name
          end
          ,FieldSuffix  = case
            when right(c.name, 5) = '_TYPE' then '.Тип'
            when right(c.name, 2) = '_L' then '.Булево'
            when right(c.name, 2) = '_N' then '.Число'
            when right(c.name, 2) = '_T' then '.Дата'
            when right(c.name, 2) = '_S' then '.Строка'
            when right(c.name, 2) = '_B' then '.Двоичный'
            when right(c.name, 6) = '_RTRef' then '.ВидСсылки'
            when right(c.name, 6) = '_RRRef' then '.Ссылка'
            else ''
          end
    from sys.tables t
        ,sys.columns c
    where t.object_id = c.object_id
      and t.name like '[_]Reference[0-9]%[_]VT[0-9]%'
    union all

    -- Документ
    select DataType     = 'Document'
          ,TableName    = t.name
          ,FieldName    = c.name
          ,TablePrefix  = 'Документ.'
          ,TableNumber  = substring(t.name, 10, patindex('%[^0-9]%', substring(t.name, 10, 10) + '.') - 1)
          ,TableSuffix  = ''
          ,VTPrefix     = ''
          ,VTNumber     = ''
          ,VTSuffix     = ''
          ,FieldPrefix  = ''
          ,FieldNumber  = case
            when left(c.name, 4) = '_Fld' then substring(c.name, 5, patindex('%[^0-9]%', substring(c.name, 5, 10) + '.') - 1)
            else c.name
          end
          ,FieldSuffix  = case
            when right(c.name, 5) = '_TYPE' then '.Тип'
            when right(c.name, 2) = '_L' then '.Булево'
            when right(c.name, 2) = '_N' then '.Число'
            when right(c.name, 2) = '_T' then '.Дата'
            when right(c.name, 2) = '_S' then '.Строка'
            when right(c.name, 2) = '_B' then '.Двоичный'
            when right(c.name, 6) = '_RTRef' then '.ВидСсылки'
            when right(c.name, 6) = '_RRRef' then '.Ссылка'
            else ''
          end
    from sys.tables t
        ,sys.columns c
    where t.object_id = c.object_id
      and t.name like '[_]Document[0-9]%'
      and t.name not like '%[_]VT[0-9]%'
    union all

    -- Документ.ТабличнаяЧасть
    select DataType     = 'VT'
          ,TableName    = t.name
          ,FieldName    = c.name
          ,TablePrefix  = 'Документ.'
          ,TableNumber  = substring(t.name, 10, patindex('%[^0-9]%', substring(t.name, 10, 10) + '.') - 1)
          ,TableSuffix  = ''
          ,VTPrefix     = '.ТабличнаяЧасть.'
          ,VTNumber     = substring(t.name, charindex('_VT', t.name) + 3, patindex('%[^0-9]%', substring(t.name, charindex('_VT', t.name) + 3, 10) + '.') - 1)
          ,VTSuffix     = ''
          ,FieldPrefix  = ''
          ,FieldNumber  = case
            when left(c.name, 4) = '_Fld' then substring(c.name, 5, patindex('%[^0-9]%', substring(c.name, 5, 10) + '.') - 1)
            when left(c.name, 9) = '_Document' and right(c.name, 7) = '_IDRRef' then right(c.name, 7)
            when left(c.name, 7) = '_LineNo' then left(c.name, 7)
            else c.name
          end
          ,FieldSuffix  = case
            when right(c.name, 5) = '_TYPE' then '.Тип'
            when right(c.name, 2) = '_L' then '.Булево'
            when right(c.name, 2) = '_N' then '.Число'
            when right(c.name, 2) = '_T' then '.Дата'
            when right(c.name, 2) = '_S' then '.Строка'
            when right(c.name, 2) = '_B' then '.Двоичный'
            when right(c.name, 6) = '_RTRef' then '.ВидСсылки'
            when right(c.name, 6) = '_RRRef' then '.Ссылка'
            else ''
          end
    from sys.tables t
        ,sys.columns c
    where t.object_id = c.object_id
      and t.name like '[_]Document[0-9]%[_]VT[0-9]%'
    union all

    -- ЖурналДокументов
    select DataType     = 'DocumentJournal'
          ,TableName    = t.name
          ,FieldName    = c.name
          ,TablePrefix  = 'ЖурналДокументов.'
          ,TableNumber  = substring(t.name, 17, patindex('%[^0-9]%', substring(t.name, 17, 10) + '.') - 1)
          ,TableSuffix  = ''
          ,VTPrefix     = ''
          ,VTNumber     = ''
          ,VTSuffix     = ''
          ,FieldPrefix  = ''
          ,FieldNumber  = case
            when left(c.name, 4) = '_Fld' then substring(c.name, 5, patindex('%[^0-9]%', substring(c.name, 5, 10) + '.') - 1)
            else c.name
          end
          ,FieldSuffix  = case
            when right(c.name, 5) = '_TYPE' then '.Тип'
            when right(c.name, 2) = '_L' then '.Булево'
            when right(c.name, 2) = '_N' then '.Число'
            when right(c.name, 2) = '_T' then '.Дата'
            when right(c.name, 2) = '_S' then '.Строка'
            when right(c.name, 2) = '_B' then '.Двоичный'
            when right(c.name, 6) = '_RTRef' then '.ВидСсылки'
            when right(c.name, 6) = '_RRRef' then '.Ссылка'
            else ''
          end
    from sys.tables t
        ,sys.columns c
    where t.object_id = c.object_id
      and t.name like '[_]DocumentJournal[0-9]%'
      and t.name not like '%[_]VT[0-9]%'
    union all

    -- РегистрСведений
    select DataType     = 'InfoRg'
          ,TableName    = t.name
          ,FieldName    = c.name
          ,TablePrefix  = 'РегистрСведений.'
          ,TableNumber  = substring(t.name, 8, patindex('%[^0-9]%', substring(t.name, 8, 10) + '.') - 1)
          ,TableSuffix  = ''
          ,VTPrefix     = ''
          ,VTNumber     = ''
          ,VTSuffix     = ''
          ,FieldPrefix  = ''
          ,FieldNumber  = case
            when left(c.name, 4) = '_Fld' then substring(c.name, 5, patindex('%[^0-9]%', substring(c.name, 5, 10) + '.') - 1)
            else c.name
          end
          ,FieldSuffix  = case
            when right(c.name, 5) = '_TYPE' then '.Тип'
            when right(c.name, 2) = '_L' then '.Булево'
            when right(c.name, 2) = '_N' then '.Число'
            when right(c.name, 2) = '_T' then '.Дата'
            when right(c.name, 2) = '_S' then '.Строка'
            when right(c.name, 2) = '_B' then '.Двоичный'
            when right(c.name, 6) = '_RTRef' then '.ВидСсылки'
            when right(c.name, 6) = '_RRRef' then '.Ссылка'
            else ''
          end
    from sys.tables t
        ,sys.columns c
    where t.object_id = c.object_id
      and t.name like '[_]InfoRg[0-9]%'
      and t.name not like '%[_]VT[0-9]%'
    union all

    -- РегистрСведений.ИтогиСрезПоследних
    select DataType     = 'InfoRgSL'
          ,TableName    = t.name
          ,FieldName    = c.name
          ,TablePrefix  = 'РегистрСведений.'
          ,TableNumber  = substring(t.name, 10, patindex('%[^0-9]%', substring(t.name, 10, 10) + '.') - 1)
          ,TableSuffix  = '.ИтогиСрезПоследних'
          ,VTPrefix     = ''
          ,VTNumber     = ''
          ,VTSuffix     = ''
          ,FieldPrefix  = ''
          ,FieldNumber  = case
            when left(c.name, 4) = '_Fld' then substring(c.name, 5, patindex('%[^0-9]%', substring(c.name, 5, 10) + '.') - 1)
            else c.name
          end
          ,FieldSuffix  = case
            when right(c.name, 5) = '_TYPE' then '.Тип'
            when right(c.name, 2) = '_L' then '.Булево'
            when right(c.name, 2) = '_N' then '.Число'
            when right(c.name, 2) = '_T' then '.Дата'
            when right(c.name, 2) = '_S' then '.Строка'
            when right(c.name, 2) = '_B' then '.Двоичный'
            when right(c.name, 6) = '_RTRef' then '.ВидСсылки'
            when right(c.name, 6) = '_RRRef' then '.Ссылка'
            else ''
          end
    from sys.tables t
        ,sys.columns c
    where t.object_id = c.object_id
      and t.name like '[_]InfoRgSL[0-9]%'
      and t.name not like '%[_]VT[0-9]%'
    union all

    -- РегистрСведений.ИтогиСрезПервых
    select DataType     = 'InfoRgSF'
          ,TableName    = t.name
          ,FieldName    = c.name
          ,TablePrefix  = 'РегистрСведений.'
          ,TableNumber  = substring(t.name, 10, patindex('%[^0-9]%', substring(t.name, 10, 10) + '.') - 1)
          ,TableSuffix  = '.ИтогиСрезПервых'
          ,VTPrefix     = ''
          ,VTNumber     = ''
          ,VTSuffix     = ''
          ,FieldPrefix  = ''
          ,FieldNumber  = case
            when left(c.name, 4) = '_Fld' then substring(c.name, 5, patindex('%[^0-9]%', substring(c.name, 5, 10) + '.') - 1)
            else c.name
          end
          ,FieldSuffix  = case
            when right(c.name, 5) = '_TYPE' then '.Тип'
            when right(c.name, 2) = '_L' then '.Булево'
            when right(c.name, 2) = '_N' then '.Число'
            when right(c.name, 2) = '_T' then '.Дата'
            when right(c.name, 2) = '_S' then '.Строка'
            when right(c.name, 2) = '_B' then '.Двоичный'
            when right(c.name, 6) = '_RTRef' then '.ВидСсылки'
            when right(c.name, 6) = '_RRRef' then '.Ссылка'
            else ''
          end
    from sys.tables t
        ,sys.columns c
    where t.object_id = c.object_id
      and t.name like '[_]InfoRgSF[0-9]%'
      and t.name not like '%[_]VT[0-9]%'
    union all

    -- РегистрНакопления
    select DataType     = 'AccumRg'
          ,TableName    = t.name
          ,FieldName    = c.name
          ,TablePrefix  = 'РегистрНакопления.'
          ,TableNumber  = substring(t.name, 9, patindex('%[^0-9]%', substring(t.name, 9, 10) + '.') - 1)
          ,TableSuffix  = ''
          ,VTPrefix     = ''
          ,VTNumber     = ''
          ,VTSuffix     = ''
          ,FieldPrefix  = ''
          ,FieldNumber  = case
            when left(c.name, 4) = '_Fld' then substring(c.name, 5, patindex('%[^0-9]%', substring(c.name, 5, 10) + '.') - 1)
            else c.name
          end
          ,FieldSuffix  = case
            when right(c.name, 5) = '_TYPE' then '.Тип'
            when right(c.name, 2) = '_L' then '.Булево'
            when right(c.name, 2) = '_N' then '.Число'
            when right(c.name, 2) = '_T' then '.Дата'
            when right(c.name, 2) = '_S' then '.Строка'
            when right(c.name, 2) = '_B' then '.Двоичный'
            when right(c.name, 6) = '_RTRef' then '.ВидСсылки'
            when right(c.name, 6) = '_RRRef' then '.Ссылка'
            else ''
          end
    from sys.tables t
        ,sys.columns c
    where t.object_id = c.object_id
      and t.name like '[_]AccumRg[0-9]%'
      and t.name not like '%[_]VT[0-9]%'
    union all

    -- РегистрНакопления.Остатки
    select DataType     = 'AccumRgT'
          ,TableName    = t.name
          ,FieldName    = c.name
          ,TablePrefix  = 'РегистрНакопления.'
          ,TableNumber  = substring(t.name, 10, patindex('%[^0-9]%', substring(t.name, 10, 10) + '.') - 1)
          ,TableSuffix  = '.Остатки'
          ,VTPrefix     = ''
          ,VTNumber     = ''
          ,VTSuffix     = ''
          ,FieldPrefix  = ''
          ,FieldNumber  = case
            when left(c.name, 4) = '_Fld' then substring(c.name, 5, patindex('%[^0-9]%', substring(c.name, 5, 10) + '.') - 1)
            else c.name
          end
          ,FieldSuffix  = case
            when right(c.name, 5) = '_TYPE' then '.Тип'
            when right(c.name, 2) = '_L' then '.Булево'
            when right(c.name, 2) = '_N' then '.Число'
            when right(c.name, 2) = '_T' then '.Дата'
            when right(c.name, 2) = '_S' then '.Строка'
            when right(c.name, 2) = '_B' then '.Двоичный'
            when right(c.name, 6) = '_RTRef' then '.ВидСсылки'
            when right(c.name, 6) = '_RRRef' then '.Ссылка'
            else ''
          end
    from sys.tables t
        ,sys.columns c
    where t.object_id = c.object_id
      and t.name like '[_]AccumRgT[0-9]%'
      and t.name not like '%[_]VT[0-9]%'
    union all

    -- РегистрНакопления.Обороты
    select DataType     = 'AccumRgTn'
          ,TableName    = t.name
          ,FieldName    = c.name
          ,TablePrefix  = 'РегистрНакопления.'
          ,TableNumber  = substring(t.name, 11, patindex('%[^0-9]%', substring(t.name, 11, 10) + '.') - 1)
          ,TableSuffix  = '.Обороты'
          ,VTPrefix     = ''
          ,VTNumber     = ''
          ,VTSuffix     = ''
          ,FieldPrefix  = ''
          ,FieldNumber  = case
            when left(c.name, 4) = '_Fld' then substring(c.name, 5, patindex('%[^0-9]%', substring(c.name, 5, 10) + '.') - 1)
            else c.name
          end
          ,FieldSuffix  = case
            when right(c.name, 5) = '_TYPE' then '.Тип'
            when right(c.name, 2) = '_L' then '.Булево'
            when right(c.name, 2) = '_N' then '.Число'
            when right(c.name, 2) = '_T' then '.Дата'
            when right(c.name, 2) = '_S' then '.Строка'
            when right(c.name, 2) = '_B' then '.Двоичный'
            when right(c.name, 6) = '_RTRef' then '.ВидСсылки'
            when right(c.name, 6) = '_RRRef' then '.Ссылка'
            else ''
          end
    from sys.tables t
        ,sys.columns c
    where t.object_id = c.object_id
      and t.name like '[_]AccumRgTn[0-9]%'
      and t.name not like '%[_]VT[0-9]%'
    union all

    -- ПланСчетов
    select DataType     = 'Acc'
          ,TableName    = t.name
          ,FieldName    = c.name
          ,TablePrefix  = 'ПланСчетов.'
          ,TableNumber  = substring(t.name, 5, patindex('%[^0-9]%', substring(t.name, 5, 10) + '.') - 1)
          ,TableSuffix  = ''
          ,VTPrefix     = ''
          ,VTNumber     = ''
          ,VTSuffix     = ''
          ,FieldPrefix  = ''
          ,FieldNumber  = case
            when left(c.name, 4) = '_Fld' then substring(c.name, 5, patindex('%[^0-9]%', substring(c.name, 5, 10) + '.') - 1)
            else c.name
          end
          ,FieldSuffix  = case
            when right(c.name, 5) = '_TYPE' then '.Тип'
            when right(c.name, 2) = '_L' then '.Булево'
            when right(c.name, 2) = '_N' then '.Число'
            when right(c.name, 2) = '_T' then '.Дата'
            when right(c.name, 2) = '_S' then '.Строка'
            when right(c.name, 2) = '_B' then '.Двоичный'
            when right(c.name, 6) = '_RTRef' then '.ВидСсылки'
            when right(c.name, 6) = '_RRRef' then '.Ссылка'
            else ''
          end
    from sys.tables t
        ,sys.columns c
    where t.object_id = c.object_id
      and t.name like '[_]Acc[0-9]%'
      and t.name not like '%[_]ExtDim[0-9]%'
      and t.name not like '%[_]VT[0-9]%'
    union all

    -- ПланСчетов.ВидыСубконто
    select DataType     = 'ExtDim'
          ,TableName    = t.name
          ,FieldName    = c.name
          ,TablePrefix  = 'ПланСчетов.'
          ,TableNumber  = substring(t.name, charindex('_ExtDim', t.name) + 7, patindex('%[^0-9]%', substring(t.name, charindex('_ExtDim', t.name) + 7, 10) + '.') - 1)
          ,TableSuffix  = '.ВидыСубконто'
          ,VTPrefix     = ''
          ,VTNumber     = ''
          ,VTSuffix     = ''
          ,FieldPrefix  = ''
          ,FieldNumber  = case
            when left(c.name, 4) = '_Fld' then substring(c.name, 5, patindex('%[^0-9]%', substring(c.name, 5, 10) + '.') - 1)
            when left(c.name, 4) = '_Acc' and right(c.name, 7) = '_IDRRef' then right(c.name, 7)
            else c.name
          end
          ,FieldSuffix  = case
            when right(c.name, 5) = '_TYPE' then '.Тип'
            when right(c.name, 2) = '_L' then '.Булево'
            when right(c.name, 2) = '_N' then '.Число'
            when right(c.name, 2) = '_T' then '.Дата'
            when right(c.name, 2) = '_S' then '.Строка'
            when right(c.name, 2) = '_B' then '.Двоичный'
            when right(c.name, 6) = '_RTRef' then '.ВидСсылки'
            when right(c.name, 6) = '_RRRef' then '.Ссылка'
            else ''
          end
    from sys.tables t
        ,sys.columns c
    where t.object_id = c.object_id
      and t.name like '[_]Acc[0-9]%[_]ExtDim[0-9]%'
    union all

    -- ПланСчетов.ТабличнаяЧасть
    select DataType     = 'VT'
          ,TableName    = t.name
          ,FieldName    = c.name
          ,TablePrefix  = 'ПланСчетов.'
          ,TableNumber  = substring(t.name, 5, patindex('%[^0-9]%', substring(t.name, 5, 10) + '.') - 1)
          ,TableSuffix  = ''
          ,VTPrefix     = '.ТабличнаяЧасть.'
          ,VTNumber     = substring(t.name, charindex('_VT', t.name) + 3, patindex('%[^0-9]%', substring(t.name, charindex('_VT', t.name) + 3, 10) + '.') - 1)
          ,VTSuffix     = ''
          ,FieldPrefix  = ''
          ,FieldNumber  = case
            when left(c.name, 4) = '_Fld' then substring(c.name, 5, patindex('%[^0-9]%', substring(c.name, 5, 10) + '.') - 1)
            when left(c.name, 4) = '_Acc' and right(c.name, 7) = '_IDRRef' then right(c.name, 7)
            when left(c.name, 7) = '_LineNo' then left(c.name, 7)
            else c.name
          end
          ,FieldSuffix  = case
            when right(c.name, 5) = '_TYPE' then '.Тип'
            when right(c.name, 2) = '_L' then '.Булево'
            when right(c.name, 2) = '_N' then '.Число'
            when right(c.name, 2) = '_T' then '.Дата'
            when right(c.name, 2) = '_S' then '.Строка'
            when right(c.name, 2) = '_B' then '.Двоичный'
            when right(c.name, 6) = '_RTRef' then '.ВидСсылки'
            when right(c.name, 6) = '_RRRef' then '.Ссылка'
            else ''
          end
    from sys.tables t
        ,sys.columns c
    where t.object_id = c.object_id
      and t.name like '[_]Acc[0-9]%[_]VT[0-9]%'
    union all

    -- РегистрБухгалтерии
    select DataType     = 'AccRg'
          ,TableName    = t.name
          ,FieldName    = c.name
          ,TablePrefix  = 'РегистрБухгалтерии.'
          ,TableNumber  = substring(t.name, 7, patindex('%[^0-9]%', substring(t.name, 7, 10) + '.') - 1)
          ,TableSuffix  = ''
          ,VTPrefix     = ''
          ,VTNumber     = ''
          ,VTSuffix     = ''
          ,FieldPrefix  = ''
          ,FieldNumber  = case
            when left(c.name, 4) = '_Fld' then substring(c.name, 5, patindex('%[^0-9]%', substring(c.name, 5, 10) + '.') - 1)
            when left(c.name, 8) = '_ValueCt' then '_ValueSubcontoCt'
            when left(c.name, 8) = '_ValueDt' then '_ValueSubcontoDt'
            when left(c.name, 6) = '_Value' then '_ValueSubconto'
            when left(c.name, 7) = '_KindCt' then '_KindSubcontoCt'
            when left(c.name, 7) = '_KindDt' then '_KindSubcontoDt'
            when left(c.name, 5) = '_Kind' then '_KindSubconto'
            else c.name
          end
          ,FieldSuffix  =
          case
            when left(c.name, 4) = '_Fld' then (case substring(c.name, 4 + patindex('%[^0-9]%', substring(c.name, 5, 10) + '.'), 2) when 'Ct' then 'Кт' when 'Dt' then 'Дт' else '' end)
            when left(c.name, 8) = '_ValueCt' then substring(c.name, 9, patindex('%[^0-9]%', substring(c.name, 9, 10) + '.') - 1)
            when left(c.name, 8) = '_ValueDt' then substring(c.name, 9, patindex('%[^0-9]%', substring(c.name, 9, 10) + '.') - 1)
            when left(c.name, 6) = '_Value' then substring(c.name, 7, patindex('%[^0-9]%', substring(c.name, 7, 10) + '.') - 1)
            when left(c.name, 7) = '_KindCt' then substring(c.name, 8, patindex('%[^0-9]%', substring(c.name, 8, 10) + '.') - 1)
            when left(c.name, 7) = '_KindDt' then substring(c.name, 8, patindex('%[^0-9]%', substring(c.name, 8, 10) + '.') - 1)
            when left(c.name, 5) = '_Kind' then substring(c.name, 6, patindex('%[^0-9]%', substring(c.name, 6, 10) + '.') - 1)
            else ''
          end +
          case
            when right(c.name, 5) = '_TYPE' then '.Тип'
            when right(c.name, 2) = '_L' then '.Булево'
            when right(c.name, 2) = '_N' then '.Число'
            when right(c.name, 2) = '_T' then '.Дата'
            when right(c.name, 2) = '_S' then '.Строка'
            when right(c.name, 2) = '_B' then '.Двоичный'
            when right(c.name, 6) = '_RTRef' then '.ВидСсылки'
            when right(c.name, 6) = '_RRRef' then '.Ссылка'
            else ''
          end
    from sys.tables t
        ,sys.columns c
    where t.object_id = c.object_id
      and t.name like '[_]AccRg[0-9]%'
    union all

    -- РегистрБухгалтерии.ЗначенияСубконто
    select DataType     = 'AccRgED'
          ,TableName    = t.name
          ,FieldName    = c.name
          ,TablePrefix  = 'РегистрБухгалтерии.'
          ,TableNumber  = substring(t.name, 9, patindex('%[^0-9]%', substring(t.name, 9, 10) + '.') - 1)
          ,TableSuffix  = '.ЗначенияСубконто'
          ,VTPrefix     = ''
          ,VTNumber     = ''
          ,VTSuffix     = ''
          ,FieldPrefix  = ''
          ,FieldNumber  = case
            when left(c.name, 4) = '_Fld' then substring(c.name, 5, patindex('%[^0-9]%', substring(c.name, 5, 10) + '.') - 1)
            when left(c.name, 6) = '_Value' then left(c.name, 6)
            else c.name
          end
          ,FieldSuffix  = case
            when right(c.name, 5) = '_TYPE' then '.Тип'
            when right(c.name, 2) = '_L' then '.Булево'
            when right(c.name, 2) = '_N' then '.Число'
            when right(c.name, 2) = '_T' then '.Дата'
            when right(c.name, 2) = '_S' then '.Строка'
            when right(c.name, 2) = '_B' then '.Двоичный'
            when right(c.name, 6) = '_RTRef' then '.ВидСсылки'
            when right(c.name, 6) = '_RRRef' then '.Ссылка'
            else ''
          end
    from sys.tables t
        ,sys.columns c
    where t.object_id = c.object_id
      and t.name like '[_]AccRgED[0-9]%'
    union all

    -- РегистрБухгалтерии.ИтогиМеждуСчетами
    select DataType     = 'AccRgCT'
          ,TableName    = t.name
          ,FieldName    = c.name
          ,TablePrefix  = 'РегистрБухгалтерии.'
          ,TableNumber  = substring(t.name, 9, patindex('%[^0-9]%', substring(t.name, 9, 10) + '.') - 1)
          ,TableSuffix  = '.ИтогиМеждуСчетами'
          ,VTPrefix     = ''
          ,VTNumber     = ''
          ,VTSuffix     = ''
          ,FieldPrefix  = ''
          ,FieldNumber  = case
            when left(c.name, 4) = '_Fld' then substring(c.name, 5, patindex('%[^0-9]%', substring(c.name, 5, 10) + '.') - 1)
            else c.name
          end
          ,FieldSuffix  =
          case
             when left(c.name, 4) = '_Fld' then (case substring(c.name, 4 + patindex('%[^0-9]%', substring(c.name, 5, 10) + '.'), 2) when 'Ct' then 'Кт' when 'Dt' then 'Дт' else '' end)
             else ''
          end +
          case
            when right(c.name, 5) = '_TYPE' then '.Тип'
            when right(c.name, 2) = '_L' then '.Булево'
            when right(c.name, 2) = '_N' then '.Число'
            when right(c.name, 2) = '_T' then '.Дата'
            when right(c.name, 2) = '_S' then '.Строка'
            when right(c.name, 2) = '_B' then '.Двоичный'
            when right(c.name, 6) = '_RTRef' then '.ВидСсылки'
            when right(c.name, 6) = '_RRRef' then '.Ссылка'
            else ''
          end
    from sys.tables t
        ,sys.columns c
    where t.object_id = c.object_id
      and t.name like '[_]AccRgCT[0-9]%'
    union all

    -- РегистрБухгалтерии.ИтогиПоСчетам
    select DataType     = 'AccRgAT'
          ,TableName    = t.name
          ,FieldName    = c.name
          ,TablePrefix  = 'РегистрБухгалтерии.'
          ,TableNumber  = substring(t.name, 9, patindex('%[^0-9]%', substring(t.name, 9, 10) + '.') - 1)
          ,TableSuffix  = case substring(t.name, 9, 1) when '0' then '.ИтогиПоСчетам' else '.ИтогиПоСчетамССубконто' + substring(t.name, 9, 1) end
          ,VTPrefix     = ''
          ,VTNumber     = ''
          ,VTSuffix     = ''
          ,FieldPrefix  = ''
          ,FieldNumber  = case
            when left(c.name, 4) = '_Fld' then substring(c.name, 5, patindex('%[^0-9]%', substring(c.name, 5, 10) + '.') - 1)
            when left(c.name, 6) = '_Value' then '_ValueSubconto'
            when left(c.name, 11) = '_TurnoverCt' then substring(c.name, 12, patindex('%[^0-9]%', substring(c.name, 12, 10) + '.') - 1)
            when left(c.name, 11) = '_TurnoverDt' then substring(c.name, 12, patindex('%[^0-9]%', substring(c.name, 12, 10) + '.') - 1)
            when left(c.name, 9) = '_Turnover' then substring(c.name, 10, patindex('%[^0-9]%', substring(c.name, 10, 10) + '.') - 1)
            else c.name
          end
          ,FieldSuffix  =
          case
            when left(c.name, 6) = '_Value' then substring(c.name, 7, patindex('%[^0-9]%', substring(c.name, 7, 10) + '.') - 1)
            when left(c.name, 11) = '_TurnoverCt' then 'Кт'
            when left(c.name, 11) = '_TurnoverDt' then 'Дт'
            else ''
          end +
          case
            when right(c.name, 5) = '_TYPE' then '.Тип'
            when right(c.name, 2) = '_L' then '.Булево'
            when right(c.name, 2) = '_N' then '.Число'
            when right(c.name, 2) = '_T' then '.Дата'
            when right(c.name, 2) = '_S' then '.Строка'
            when right(c.name, 2) = '_B' then '.Двоичный'
            when right(c.name, 6) = '_RTRef' then '.ВидСсылки'
            when right(c.name, 6) = '_RRRef' then '.Ссылка'
            else ''
          end
    from sys.tables t
        ,sys.columns c
    where t.object_id = c.object_id
      and t.name like '[_]AccRgAT[0-9]%'
    union all

    -- ПланВидовРасчета
    select DataType     = 'CKinds'
          ,TableName    = t.name
          ,FieldName    = c.name
          ,TablePrefix  = 'ПланВидовРасчета.'
          ,TableNumber  = substring(t.name, 8, patindex('%[^0-9]%', substring(t.name, 8, 10) + '.') - 1)
          ,TableSuffix  = ''
          ,VTPrefix     = ''
          ,VTNumber     = ''
          ,VTSuffix     = ''
          ,FieldPrefix  = ''
          ,FieldNumber  = case
            when left(c.name, 4) = '_Fld' then substring(c.name, 5, patindex('%[^0-9]%', substring(c.name, 5, 10) + '.') - 1)
            else c.name
          end
          ,FieldSuffix  = case
            when right(c.name, 5) = '_TYPE' then '.Тип'
            when right(c.name, 2) = '_L' then '.Булево'
            when right(c.name, 2) = '_N' then '.Число'
            when right(c.name, 2) = '_T' then '.Дата'
            when right(c.name, 2) = '_S' then '.Строка'
            when right(c.name, 2) = '_B' then '.Двоичный'
            when right(c.name, 6) = '_RTRef' then '.ВидСсылки'
            when right(c.name, 6) = '_RRRef' then '.Ссылка'
            else ''
          end
    from sys.tables t
        ,sys.columns c
    where t.object_id = c.object_id
      and t.name like '[_]CKinds[0-9]%'
      and t.name not like '%[_]LeadingCK%'
      and t.name not like '%[_]BaseCK%'
      and t.name not like '%[_]DisplacedCK%'
      and t.name not like '%[_]VT[0-9]%'
    union all

    -- ПланВидовРасчета.ВедущиеВидыРасчета
    select DataType     = 'CKinds'
          ,TableName    = t.name
          ,FieldName    = c.name
          ,TablePrefix  = 'ПланВидовРасчета.'
          ,TableNumber  = substring(t.name, 8, patindex('%[^0-9]%', substring(t.name, 8, 10) + '.') - 1)
          ,TableSuffix  = '.ВедущиеВидыРасчета'
          ,VTPrefix     = ''
          ,VTNumber     = ''
          ,VTSuffix     = ''
          ,FieldPrefix  = ''
          ,FieldNumber  = case
            when left(c.name, 4) = '_Fld' then substring(c.name, 5, patindex('%[^0-9]%', substring(c.name, 5, 10) + '.') - 1)
            when left(c.name, 7) = '_CKinds' and right(c.name, 7) = '_IDRRef' then right(c.name, 7)
            when left(c.name, 19) = '_LeadingCKLeadingCK' then left(c.name, 19)
            when c.name = '_LeadingCKLineNo' then '_LineNo'
            when c.name = '_PredefinedLeadingCKTableLine' then '_PredefinedID'
            else c.name
          end
          ,FieldSuffix  = case
            when right(c.name, 5) = '_TYPE' then '.Тип'
            when right(c.name, 2) = '_L' then '.Булево'
            when right(c.name, 2) = '_N' then '.Число'
            when right(c.name, 2) = '_T' then '.Дата'
            when right(c.name, 2) = '_S' then '.Строка'
            when right(c.name, 2) = '_B' then '.Двоичный'
            when right(c.name, 6) = '_RTRef' then '.ВидСсылки'
            when right(c.name, 6) = '_RRRef' then '.Ссылка'
            else ''
          end
    from sys.tables t
        ,sys.columns c
    where t.object_id = c.object_id
      and t.name like '[_]CKinds[0-9]%[_]LeadingCK%'
    union all

    -- ПланВидовРасчета.БазовыеВидыРасчета
    select DataType     = 'CKinds'
          ,TableName    = t.name
          ,FieldName    = c.name
          ,TablePrefix  = 'ПланВидовРасчета.'
          ,TableNumber  = substring(t.name, 8, patindex('%[^0-9]%', substring(t.name, 8, 10) + '.') - 1)
          ,TableSuffix  = '.БазовыеВидыРасчета'
          ,VTPrefix     = ''
          ,VTNumber     = ''
          ,VTSuffix     = ''
          ,FieldPrefix  = ''
          ,FieldNumber  = case
            when left(c.name, 4) = '_Fld' then substring(c.name, 5, patindex('%[^0-9]%', substring(c.name, 5, 10) + '.') - 1)
            when left(c.name, 7) = '_CKinds' and right(c.name, 7) = '_IDRRef' then right(c.name, 7)
            when left(c.name, 13) = '_BaseCKBaseCK' then left(c.name, 13)
            when c.name = '_BaseCKLineNo' then '_LineNo'
            when c.name = '_PredefinedBaseCKTableLine' then '_PredefinedID'
            else c.name
          end
          ,FieldSuffix  = case
            when right(c.name, 5) = '_TYPE' then '.Тип'
            when right(c.name, 2) = '_L' then '.Булево'
            when right(c.name, 2) = '_N' then '.Число'
            when right(c.name, 2) = '_T' then '.Дата'
            when right(c.name, 2) = '_S' then '.Строка'
            when right(c.name, 2) = '_B' then '.Двоичный'
            when right(c.name, 6) = '_RTRef' then '.ВидСсылки'
            when right(c.name, 6) = '_RRRef' then '.Ссылка'
            else ''
          end
    from sys.tables t
        ,sys.columns c
    where t.object_id = c.object_id
      and t.name like '[_]CKinds[0-9]%[_]BaseCK%'
    union all

    -- ПланВидовРасчета.ВытесняющиеВидыРасчета
    select DataType     = 'CKinds'
          ,TableName    = t.name
          ,FieldName    = c.name
          ,TablePrefix  = 'ПланВидовРасчета.'
          ,TableNumber  = substring(t.name, 8, patindex('%[^0-9]%', substring(t.name, 8, 10) + '.') - 1)
          ,TableSuffix  = '.ВытесняющиеВидыРасчета'
          ,VTPrefix     = ''
          ,VTNumber     = ''
          ,VTSuffix     = ''
          ,FieldPrefix  = ''
          ,FieldNumber  = case
            when left(c.name, 4) = '_Fld' then substring(c.name, 5, patindex('%[^0-9]%', substring(c.name, 5, 10) + '.') - 1)
            when left(c.name, 7) = '_CKinds' and right(c.name, 7) = '_IDRRef' then right(c.name, 7)
            when left(c.name, 19) = '_DisplacedCKDisplCK' then left(c.name, 19)
            when c.name = '_DisplacedCKLineNo' then '_LineNo'
            when c.name = '_PredefinedDisplacedCKTableLine' then '_PredefinedID'
            else c.name
          end
          ,FieldSuffix  = case
            when right(c.name, 5) = '_TYPE' then '.Тип'
            when right(c.name, 2) = '_L' then '.Булево'
            when right(c.name, 2) = '_N' then '.Число'
            when right(c.name, 2) = '_T' then '.Дата'
            when right(c.name, 2) = '_S' then '.Строка'
            when right(c.name, 2) = '_B' then '.Двоичный'
            when right(c.name, 6) = '_RTRef' then '.ВидСсылки'
            when right(c.name, 6) = '_RRRef' then '.Ссылка'
            else ''
          end
    from sys.tables t
        ,sys.columns c
    where t.object_id = c.object_id
      and t.name like '[_]CKinds[0-9]%[_]DisplacedCK%'
    union all

    -- ПланВидовРасчета.ТабличнаяЧасть
    select DataType     = 'VT'
          ,TableName    = t.name
          ,FieldName    = c.name
          ,TablePrefix  = 'ПланВидовРасчета.'
          ,TableNumber  = substring(t.name, 8, patindex('%[^0-9]%', substring(t.name, 8, 10) + '.') - 1)
          ,TableSuffix  = ''
          ,VTPrefix     = '.ТабличнаяЧасть.'
          ,VTNumber     = substring(t.name, charindex('_VT', t.name) + 3, patindex('%[^0-9]%', substring(t.name, charindex('_VT', t.name) + 3, 10) + '.') - 1)
          ,VTSuffix     = ''
          ,FieldPrefix  = ''
          ,FieldNumber  = case
            when left(c.name, 4) = '_Fld' then substring(c.name, 5, patindex('%[^0-9]%', substring(c.name, 5, 10) + '.') - 1)
            when left(c.name, 7) = '_CKinds' and right(c.name, 7) = '_IDRRef' then right(c.name, 7)
            when left(c.name, 7) = '_LineNo' then left(c.name, 7)
            else c.name
          end
          ,FieldSuffix  = case
            when right(c.name, 5) = '_TYPE' then '.Тип'
            when right(c.name, 2) = '_L' then '.Булево'
            when right(c.name, 2) = '_N' then '.Число'
            when right(c.name, 2) = '_T' then '.Дата'
            when right(c.name, 2) = '_S' then '.Строка'
            when right(c.name, 2) = '_B' then '.Двоичный'
            when right(c.name, 6) = '_RTRef' then '.ВидСсылки'
            when right(c.name, 6) = '_RRRef' then '.Ссылка'
            else ''
          end
    from sys.tables t
        ,sys.columns c
    where t.object_id = c.object_id
      and t.name like '[_]CKinds[0-9]%[_]VT[0-9]%'
  ) t
) t
where DN = 1
order by TableNumber
        ,TablePrefix
        ,TableSuffix
        ,VTNumber
        ,VTPrefix
        ,VTSuffix
        ,FieldNumber
        ,FieldPrefix
        ,FieldSuffix
