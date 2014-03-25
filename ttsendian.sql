select platform_name my_platform, 
endian_format my_endian_format 
from v$transportable_platform 
join v$database using(platform_name);
