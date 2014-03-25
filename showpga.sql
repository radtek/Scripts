prompt avaliar cache hit percentagem, que indica se houve falta de memória para algum processo
select name, ROUND(value / 1024 / 1024, 2) as MB
from v$pgastat;