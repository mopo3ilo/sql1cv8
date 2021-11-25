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
        ,FieldPrefix  = case
          when c.name = '_RecordKey' then 'КлючЗаписи'
          else ''
        end
        ,FieldNumber  = case
          when left(c.name, 4) = '_Fld' then substring(c.name, 5, patindex('%[^0-9]%', substring(c.name, 5, 10) + '.') - 1)
          else ''
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
        ,FieldPrefix  = case
          when c.name = '_EnumOrder' then 'Порядок'
          when c.name = '_IDRRef' then 'Ссылка'
          else ''
        end
        ,FieldNumber  = ''
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
        ,FieldPrefix  = case
          when c.name = '_IDRRef' then 'Ссылка'
          when c.name = '_ParentIDRRef' then 'Родитель'
          when left(c.name, 8) = '_OwnerID' then 'Владелец'
          when c.name = '_PredefinedID' then 'Предопределенное'
          when c.name = '_Version' then 'Версия'
          when c.name = '_Marked' then 'ПометкаУдаления'
          when c.name = '_Folder' then 'Группа'
          when c.name = '_Code' then 'Код'
          when c.name = '_Description' then 'Наименование'
          when c.name = '_Type' then 'ТипЗначения'
          else ''
        end
        ,FieldNumber  = case
          when left(c.name, 4) = '_Fld' then substring(c.name, 5, patindex('%[^0-9]%', substring(c.name, 5, 10) + '.') - 1)
          else ''
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
        ,FieldPrefix  = case
          when c.name = '_IDRRef' then 'Ссылка'
          when c.name = '_ParentIDRRef' then 'Родитель'
          when left(c.name, 8) = '_OwnerID' then 'Владелец'
          when c.name = '_PredefinedID' then 'Предопределенное'
          when c.name = '_Version' then 'Версия'
          when c.name = '_Marked' then 'ПометкаУдаления'
          when c.name = '_Folder' then 'Группа'
          when c.name = '_Code' then 'Код'
          when c.name = '_Description' then 'Наименование'
          else ''
        end
        ,FieldNumber  = case
          when left(c.name, 4) = '_Fld' then substring(c.name, 5, patindex('%[^0-9]%', substring(c.name, 5, 10) + '.') - 1)
          else ''
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
        ,FieldPrefix  = case
          when c.name = '_IDRRef' then 'Ссылка'
          when c.name = '_Version' then 'Версия'
          when c.name = '_Marked' then 'ПометкаУдаления'
          when c.name = '_Posted' then 'Проведен'
          when c.name = '_Date_Time' then 'Дата'
          when c.name = '_NumberPrefix' then 'Префикс'
          when c.name = '_Number' then 'Номер'
          else ''
        end
        ,FieldNumber  = case
          when left(c.name, 4) = '_Fld' then substring(c.name, 5, patindex('%[^0-9]%', substring(c.name, 5, 10) + '.') - 1)
          else ''
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
        ,FieldPrefix  = case
          when c.name = '_Period' then 'Период'
          when c.name = '_RecorderRRef' then 'Регистратор'
          when c.name = '_RecorderTRef' then 'ВидРегистратора'
          when c.name = '_Active' then 'Активность'
          when c.name = '_LineNo' then 'НомерСтроки'
          else ''
        end
        ,FieldNumber  = case
          when left(c.name, 4) = '_Fld' then substring(c.name, 5, patindex('%[^0-9]%', substring(c.name, 5, 10) + '.') - 1)
          else ''
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
        ,FieldPrefix  = case
          when c.name = '_Period' then 'Период'
          when c.name = '_RecorderRRef' then 'Регистратор'
          when c.name = '_RecorderTRef' then 'ВидРегистратора'
          else ''
        end
        ,FieldNumber  = case
          when left(c.name, 4) = '_Fld' then substring(c.name, 5, patindex('%[^0-9]%', substring(c.name, 5, 10) + '.') - 1)
          else ''
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
        ,FieldPrefix  = case
          when c.name = '_Period' then 'Период'
          when c.name = '_RecorderRRef' then 'Регистратор'
          when c.name = '_RecorderTRef' then 'ВидРегистратора'
          else ''
        end
        ,FieldNumber  = case
          when left(c.name, 4) = '_Fld' then substring(c.name, 5, patindex('%[^0-9]%', substring(c.name, 5, 10) + '.') - 1)
          else ''
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
        ,FieldPrefix  = case
          when c.name = '_Period' then 'Период'
          when c.name = '_RecorderRRef' then 'Регистратор'
          when c.name = '_RecorderTRef' then 'ВидРегистратора'
          when c.name = '_Active' then 'Активность'
          when c.name = '_LineNo' then 'НомерСтроки'
          when c.name = '_RecordKind' then 'ВидДвижения'
          when c.name = '_DimHash' then 'ХэшИзмерений'
          else ''
        end
        ,FieldNumber  = case
          when left(c.name, 4) = '_Fld' then substring(c.name, 5, patindex('%[^0-9]%', substring(c.name, 5, 10) + '.') - 1)
          else ''
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
        ,FieldPrefix  = case
          when c.name = '_Period' then 'Период'
          when c.name = '_Splitter' then 'Разделитель'
          when c.name = '_DimHash' then 'ХэшИзмерений'
          else ''
        end
        ,FieldNumber  = case
          when left(c.name, 4) = '_Fld' then substring(c.name, 5, patindex('%[^0-9]%', substring(c.name, 5, 10) + '.') - 1)
          else ''
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
        ,FieldPrefix  = case
          when c.name = '_Period' then 'Период'
          when c.name = '_Splitter' then 'Разделитель'
          when c.name = '_DimHash' then 'ХэшИзмерений'
          else ''
        end
        ,FieldNumber  = case
          when left(c.name, 4) = '_Fld' then substring(c.name, 5, patindex('%[^0-9]%', substring(c.name, 5, 10) + '.') - 1)
          else ''
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
        ,FieldPrefix  = case
          when right(c.name, 7) = '_IDRRef' then 'Ссылка'
          when c.name = '_KeyField' then 'КлючЗаписи'
          when left(c.name, 7) = '_LineNo' then 'НомерСтроки'
          else ''
        end
        ,FieldNumber  = case
          when left(c.name, 4) = '_Fld' then substring(c.name, 5, patindex('%[^0-9]%', substring(c.name, 5, 10) + '.') - 1)
          else ''
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
        ,FieldPrefix  = case
          when right(c.name, 7) = '_IDRRef' then 'Ссылка'
          when c.name = '_KeyField' then 'КлючЗаписи'
          when left(c.name, 7) = '_LineNo' then 'НомерСтроки'
          else ''
        end
        ,FieldNumber  = case
          when left(c.name, 4) = '_Fld' then substring(c.name, 5, patindex('%[^0-9]%', substring(c.name, 5, 10) + '.') - 1)
          else ''
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
        ,FieldPrefix  = case
          when right(c.name, 7) = '_IDRRef' then 'Ссылка'
          when c.name = '_KeyField' then 'КлючЗаписи'
          when left(c.name, 7) = '_LineNo' then 'НомерСтроки'
          else ''
        end
        ,FieldNumber  = case
          when left(c.name, 4) = '_Fld' then substring(c.name, 5, patindex('%[^0-9]%', substring(c.name, 5, 10) + '.') - 1)
          else ''
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