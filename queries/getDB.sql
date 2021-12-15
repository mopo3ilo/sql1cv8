select * from (
  -- Константа
  select DataType     = 'Const'
        ,TableName    = t.name
        ,FieldName    = c.name
        ,TablePrefix  = 'Константа.'
        ,TableNumber  = substring(t.name, 7, 10)
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
        ,TableNumber  = substring(t.name, 6, 10)
        ,TableSuffix  = ''
        ,VTPrefix     = ''
        ,VTNumber     = ''
        ,VTSuffix     = ''
        ,FieldPrefix  = ''
        ,FieldNumber  = c.name
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
    and t.name like '[_]Enum[0-9]%'
    and t.name not like '%[_]VT[0-9]%'
  union all

  -- ПланВидовХарактеристик
  select DataType     = 'Chrc'
        ,TableName    = t.name
        ,FieldName    = c.name
        ,TablePrefix  = 'ПланВидовХарактеристик.'
        ,TableNumber  = substring(t.name, 6, 10)
        ,TableSuffix  = ''
        ,VTPrefix     = ''
        ,VTNumber     = ''
        ,VTSuffix     = ''
        ,FieldPrefix  = ''
        ,FieldNumber  = case
          when left(c.name, 4) = '_Fld' then substring(c.name, 5, patindex('%[^0-9]%', substring(c.name, 5, 10) + '.') - 1)
          when left(c.name, 8) = '_OwnerID' then '_OwnerID'
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

  -- Справочник
  select DataType     = 'Reference'
        ,TableName    = t.name
        ,FieldName    = c.name
        ,TablePrefix  = 'Справочник.'
        ,TableNumber  = substring(t.name, 11, 10)
        ,TableSuffix  = ''
        ,VTPrefix     = ''
        ,VTNumber     = ''
        ,VTSuffix     = ''
        ,FieldPrefix  = ''
        ,FieldNumber  = case
          when left(c.name, 4) = '_Fld' then substring(c.name, 5, patindex('%[^0-9]%', substring(c.name, 5, 10) + '.') - 1)
          when left(c.name, 8) = '_OwnerID' then '_OwnerID'
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

  -- Документ
  select DataType     = 'Document'
        ,TableName    = t.name
        ,FieldName    = c.name
        ,TablePrefix  = 'Документ.'
        ,TableNumber  = substring(t.name, 10, 10)
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

  -- РегистрСведений
  select DataType     = 'InfoRg'
        ,TableName    = t.name
        ,FieldName    = c.name
        ,TablePrefix  = 'РегистрСведений.'
        ,TableNumber  = substring(t.name, 8, 10)
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
        ,TableNumber  = substring(t.name, 10, 10)
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
        ,TableNumber  = substring(t.name, 10, 10)
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
        ,TableNumber  = substring(t.name, 9, 10)
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
        ,TableNumber  = substring(t.name, 10, 10)
        ,TableSuffix  = '.Итоги'
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
        ,TableNumber  = substring(t.name, 11, 10)
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
          when left(c.name, 5) = '_Chrc' and right(c.name, 7) = '_IDRRef' then '_IDRRef'
          when left(c.name, 7) = '_LineNo' then '_LineNo'
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
          when left(c.name, 10) = '_Reference' and right(c.name, 7) = '_IDRRef' then '_IDRRef'
          when left(c.name, 7) = '_LineNo' then '_LineNo'
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
          when left(c.name, 9) = '_Document' and right(c.name, 7) = '_IDRRef' then '_IDRRef'
          when left(c.name, 7) = '_LineNo' then '_LineNo'
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
) t
order by TableNumber
        ,TablePrefix
        ,TableSuffix
        ,VTNumber
        ,VTPrefix
        ,VTSuffix
        ,FieldNumber
        ,FieldPrefix
        ,FieldSuffix