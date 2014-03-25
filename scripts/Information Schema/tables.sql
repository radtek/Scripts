/*
This software has been released under the MIT license:

  Copyright (c) 2009 Lewis R Cunningham

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in
  all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
  THE SOFTWARE.
*/ 
CREATE OR REPLACE VIEW tables 
AS
SELECT * FROM (
  SELECT SYS_CONTEXT('userenv', 'DB_NAME') TABLE_CATALOG, 
         owner TABLE_SCHEMA,
         TABLE_NAME,
         case 
         when iot_type = 'Y'
           then 'IOT'
         when temporary = 'Y'
           then 'TEMP'
         else
          'BASE TABLE'
         end table_type         
    FROM all_tables
    UNION ALL
    SELECT SYS_CONTEXT('userenv', 'DB_NAME') TABLE_CATALOG,
           owner TABLE_SCHEMA,
           view_name table_name, 
           'VIEW' table_type
    FROM all_views    
) tables;
/

grant select on tables to public;

create or replace public synonym tables for information_schema.tables;
