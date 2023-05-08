
--Problema 1.4: Consultas agrupadas: Cláusula HAVING

--1. Se necesita saber el importe total de cada factura, pero solo aquellas 
--donde ese importe total sea superior a 2500

select nro_factura, sum(cantidad*pre_unitario) 'Importe total'
from detalle_facturas
group by nro_factura
having sum(cantidad*pre_unitario) > 2500

--2. Se desea un listado de vendedores y sus importes de ventas del año 2017 
--pero solo aquellos que vendieron menos de $ 17.000.- en dicho año.

select v.cod_vendedor, nom_vendedor +','+ ape_vendedor 'Vendedor', sum(cantidad*pre_unitario) 'Importe total'
from vendedores as v join facturas as f on v.cod_vendedor = f.cod_vendedor
join detalle_facturas as df on df.nro_factura = f.nro_factura
where YEAR(f.fecha) = 2017
group by v.cod_vendedor, nom_vendedor +','+ ape_vendedor
having sum(cantidad*pre_unitario) < 17000

--3. Se quiere saber la fecha de la primera venta, la cantidad total de unidades vendidas y 
--el importe total vendido por vendedor para los casos en que el promedio 
--de la cantidad vendida sea inferior o igual a 56.

select f.cod_vendedor,nom_vendedor +','+ape_vendedor 'Vendedor', min(format(f.fecha, 'dd/MM/yyyy')) 'Fecha Primer venta', 
sum(cantidad) 'Cantidad de unidades Vendidas',
sum(cantidad*pre_unitario) 'Importe total vendido', 
sum(cantidad*pre_unitario)/count(distinct f.nro_factura) 'Promedio x factura'
from facturas as f join detalle_facturas as df on f.nro_factura = df.nro_factura
join vendedores as v on v.cod_vendedor = f.cod_vendedor
group by f.cod_vendedor, nom_vendedor +','+ape_vendedor
having sum(cantidad)/count(distinct f.nro_factura) <= 56

--4. Se necesita un listado que informe sobre el subtotal(por detalle) máximo, minimo e importe total 
--total que gastó en esta librería cada cliente el año pasado, pero solo 
--gastado por esos clientes esté entre 1000 y 8000.

select c.cod_cliente, nom_cliente +','+ape_cliente 'Cliente', 
max(cantidad*pre_unitario) 'Monto Max.', min(cantidad*pre_unitario) 'Monto Min.',
sum(cantidad*pre_unitario) 'Total'
from clientes as c join facturas as f on f.cod_cliente = c.cod_cliente
join detalle_facturas as df on df.nro_factura = f.nro_factura
where YEAR(fecha) = year(getdate())-1
group by c.cod_cliente, nom_cliente +','+ ape_cliente
having sum(cantidad*pre_unitario) between 1000 and 5000

--5. Muestre la cantidad facturas diarias por vendedor; para los casos en que 
--esa cantidad sea 2 o más.

select v.cod_vendedor, day(fecha) 'Dia', month(fecha)'Mes', year(fecha)'Año',
count(distinct f.nro_factura) 'Cantidad de Facturas'
from facturas as f join vendedores as v on f.cod_vendedor = v.cod_vendedor
group by v.cod_vendedor, day(fecha), month(fecha), year(fecha)
having count(*) >= 2

--6. Desde la administración se solicita un reporte que muestre el precio 
--promedio, el importe total y el promedio del importe vendido por artículo 
--que no comiencen con “c”, que su cantidad total vendida sea 100 o más 
--o que ese importe total vendido sea superior a 700.

select a.cod_articulo, descripcion, sum(cantidad*df.pre_unitario) 'Imp. Total',
sum(cantidad*df.pre_unitario)/sum(cantidad) 'Precio Promedio', 
sum(cantidad) 'Cant. Total Vendida',
avg(df.pre_unitario) 'Promedio Simple',
sum(cantidad*df.pre_unitario)/count(distinct f.nro_factura) 'Promedio de imp vendido'
from facturas as f join detalle_facturas as df on f.nro_factura = df.nro_factura
join articulos as a on a.cod_articulo = df.cod_articulo
where descripcion  not like 'c%'
group by a.cod_articulo, descripcion
having sum(cantidad) >= 100 or sum(cantidad*df.pre_unitario) > 700

--7. Muestre en un listado la cantidad total de artículos vendidos, el importe 
--total y la fecha de la primer y última venta por cada cliente, para lo 
--números de factura que no sean los siguientes: 2, 12, 20, 17, 30 y que el 
--promedio de la cantidad vendida oscile entre 2 y 6. 

select c.cod_cliente, ape_cliente +','+nom_cliente 'Cliente', sum(cantidad) 'Cant. Total', 
sum(cantidad*df.pre_unitario) 'Importe total',
min(fecha) 'Primer venta', 
max(fecha) 'Ultima venta', 
avg(cantidad) 'Promedio x detalle'
from facturas as f join detalle_facturas as df on f.nro_factura = df.nro_factura
join clientes as c on c.cod_cliente = f.cod_cliente
join articulos as a on a.cod_articulo = df.cod_articulo
where f.nro_factura not in (2,12,20,17,30)
group by c.cod_cliente, ape_cliente +','+nom_cliente
having avg(cantidad) between 2 and 60

--8. Emitir un listado que muestre la cantidad total de artículos vendidos, el 
--importe total vendido y el promedio del importe vendido por vendedor y 
--por cliente; para los casos en que el importe total vendido esté entre 200 
--y 600 y para códigos de cliente que oscilen entre 1 y 5.

select c.cod_cliente, v.cod_vendedor, nom_vendedor +','+ape_vendedor 'Vendedor', sum(cantidad) 'Cant', sum(cantidad*df.pre_unitario) 'Imp. Total', 
sum(cantidad*df.pre_unitario)/count(f.nro_factura) 'Promedio vendido'
from facturas as f join detalle_facturas as df on f.nro_factura = df.nro_factura
join articulos as a on a.cod_articulo = df.cod_articulo
join vendedores as v on v.cod_vendedor = f.cod_vendedor
join clientes as c on c.cod_cliente = f.cod_cliente
where c.cod_cliente between 1 and 5
group by c.cod_cliente, v.cod_vendedor, nom_vendedor +','+ape_vendedor
having sum(cantidad*df.pre_unitario) between 100000 and 200000

--9. ¿Cuáles son los vendedores cuyo promedio de facturación el mes 
--pasado supera los $ 800?

select v.cod_vendedor, nom_vendedor +','+ape_vendedor 'Vendedor', 
sum(cantidad*pre_unitario)/count(distinct f.nro_factura) 'Promedio x Factura'
from vendedores as v join facturas as f on v.cod_vendedor = f.cod_vendedor
join detalle_facturas as df on df.nro_factura = f.nro_factura
where datediff(month, fecha, getdate()) = 1
group by v.cod_vendedor, nom_vendedor +','+ ape_vendedor
having sum(cantidad*pre_unitario)/count(distinct f.nro_factura) > 800

--10.¿Cuánto le vendió cada vendedor a cada cliente el año pasado siempre
--que la cantidad de facturas emitidas (por cada vendedor a cada cliente) 
--sea menor a 5?

select v.cod_vendedor, c.cod_cliente, nom_vendedor +','+ape_vendedor 'Vendedor',
nom_cliente +','+ape_cliente 'Cliente', 
sum(cantidad*pre_unitario) 'Vendido Total'
from clientes as c join facturas as f on c.cod_cliente = f.cod_cliente
join detalle_facturas as df on df.nro_factura = f.nro_factura
join vendedores as v on v.cod_vendedor = f.cod_vendedor
where year(fecha) = year(getdate())-1
group by v.cod_vendedor, nom_vendedor +','+ape_vendedor, c.cod_cliente, nom_cliente +','+ape_cliente
having count(distinct f.nro_factura) < 5