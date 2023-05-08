-- CLASE 25/08 UNIDAD 1 GROUP BY


-- mostrar cuantas facturas hizo CADA UNO de los  vendedor este anio
-- con codigo 1, el promedio factura, el monto total, fecha de la primera y ultima vente

select v.cod_vendedor 'Codigo Vendedor', nom_vendedor 'Nombre',ape_vendedor 'Apellido', count(distinct f.nro_factura) 'Cant. facturas', sum(cantidad*pre_unitario)/count(distinct f.nro_factura) 'Promedio por factura', 
sum(cantidad*pre_unitario)'MOnto total', 
min(f.fecha)'Primera fecha', max(f.fecha) 'Ultima fecha'
from facturas as f join detalle_facturas as df on f.nro_factura = df.nro_factura
join vendedores as v on v.cod_vendedor = f.cod_vendedor
where year(fecha) = year(getdate())
group by v.cod_vendedor, nom_vendedor, ape_vendedor
--select * from facturas

--cuanto le facturo cada vendedor a cada cliente ?

select cod_vendedor, cod_cliente, sum(cantidad*pre_unitario) 'Total'
from facturas as f join detalle_facturas as df on f.nro_factura = df.nro_factura
group by cod_vendedor, cod_cliente
order by 1, 2

--cuanto le facturo cada vendedor a cada cliente este año ?
select cod_vendedor, cod_cliente, sum(cantidad*pre_unitario) 'Total'
from facturas as f join detalle_facturas as df on f.nro_factura = df.nro_factura 
where year(fecha) = year(getdate())
group by cod_vendedor, cod_cliente
order by 1, 2

-- cuantas facturas hizo cada vendedor a cada cliente ?
-- solo cuando el vendedor le haya facturado a cada cliente mas de 3000 en promedio por detalle

select cod_vendedor, cod_cliente, sum(cantidad*pre_unitario) 'Total', count(distinct f.nro_factura) 'Cant. Facturas'
from facturas as f join detalle_facturas as df on f.nro_factura = df.nro_factura 
where year(fecha) = year(getdate())
group by cod_vendedor, cod_cliente
having avg(cantidad*pre_unitario) > 3000 -- condicion de busqueda como el wheare
order by 1, 2

--Problema 1.3: Consultas agrupadas: Cláusula GROUP BY

--1. Los importes totales de ventas por cada artículo que se tiene en el 
--negocio

select cod_articulo 'Cod. Articulo', sum(cantidad*pre_unitario) 'Total x Articulo'
from facturas as f join detalle_facturas as df on f.nro_factura = df.nro_factura
group by cod_articulo

---- 2. Por cada factura emitida mostrar la cantidad total de artículos vendidos 
--(suma de las cantidades vendidas), la cantidad ítems que tiene cada 
--factura en el detalle (cantidad de registros de detalles) y el Importe total 
--de la facturación de este año.

select f.nro_factura, sum(df.cantidad) 'Cantidad de articulos Vendidos', count(df.nro_factura) 'Cant. registro Detalle',
sum(cantidad*pre_unitario) 'Importe'
from facturas as f join detalle_facturas as df on f.nro_factura = df.nro_factura
where year(fecha) = year(getdate())
group by f.nro_factura

---- 3. Se quiere saber en este negocio, cuánto se factura:
--a. Diariamente 
--b. Mensualmente 
--c. Anualmente 


-- diario
select day(fecha) 'Dia', month(fecha) 'Mes', year(fecha) 'Año', sum(cantidad*pre_unitario) 'Importe del dia' 
from facturas as f join detalle_facturas as df on f.nro_factura = df.nro_factura
group by day(fecha), month(fecha), year(fecha)
order by 3,2,1

-- mensual

select month(fecha) 'Mes', year(fecha) 'Año', sum(cantidad*pre_unitario) 'Importe del Mes' 
from facturas as f join detalle_facturas as df on f.nro_factura = df.nro_factura
group by month(fecha), year(fecha)
order by 2,3

-- anual
select year(fecha) 'Año', sum(cantidad*pre_unitario) 'Importe del Año' 
from facturas as f join detalle_facturas as df on f.nro_factura = df.nro_factura
group by year(fecha)
order by 1

----4. Emitir un listado de la cantidad de facturas confeccionadas diariamente, 
--correspondiente a los meses que no sean enero, julio ni diciembre. 
--Ordene por la cantidad de facturas en forma descendente y fecha.

select count(*) 'Cant. Facturas', FORMAT(fecha, 'dd/MM/yyyy')
from facturas
where month(fecha) not in (1,7,12)
group by fecha
order by 1 desc, fecha

--5. Se quiere saber la cantidad y el importe promedio vendido por fecha y 
--cliente, para códigos de vendedor superiores a 2. Ordene por fecha y 
--cliente.


select fecha, c.cod_cliente, ape_cliente + ' ' + nom_cliente 'Cliente',
sum(cantidad) 'Cantidad Vendida', avg(cantidad*pre_unitario) 'Promedio vendido por detalle',
sum(cantidad*pre_unitario)/count(distinct f.nro_factura) 'Promedio vendido por factura'
from facturas as f join detalle_facturas as df on f.nro_factura = df.nro_factura
join clientes as c on c.cod_cliente = f.cod_cliente
join vendedores as v on v.cod_vendedor = f.cod_vendedor
where v.cod_vendedor > 2
group by fecha, c.cod_cliente, ape_cliente + ' ' + nom_cliente
order by fecha, Cliente

--6. Se quiere saber el importe promedio vendido y la cantidad total vendida 
--por fecha y artículo, para códigos de cliente inferior a 3. Ordene por fecha 
--y artículo

select fecha, cod_cliente, avg(cantidad*pre_unitario) 'Promedio por detalle', sum(cantidad) 'Cantidad total vendida',
sum(cantidad*pre_unitario)/count(distinct f.nro_factura) 'Promedio por factura'
from facturas as f join detalle_facturas as df on f.nro_factura = df.nro_factura
where cod_cliente < 3
group by fecha, cod_cliente
order by 1,2

--7. Listar la cantidad total vendida, el importe total vendido y el importe 
--promedio total vendido por número de factura, siempre que la fecha no 
--oscile entre el 13/2/2007 y el 13/7/2010.

SELECT df.nro_factura, sum(cantidad) Cantidad_Total, sum(cantidad*pre_unitario) Importe_total,
sum(cantidad*pre_unitario)/count(distinct df.nro_factura) promedio_Factura
FROM facturas f join detalle_facturas df
on f.nro_factura=df.nro_factura
WHERE fecha NOT BETWEEN '13/02/2007' AND '13/07/2010'
group by df.nro_factura

----8. Emitir un reporte que muestre la fecha de la primer y última venta y el 
--importe comprado por cliente. Rotule como CLIENTE, PRIMER VENTA, 
--ÚLTIMA VENTA, IMPORTE.

select c.cod_cliente 'Cod. Cliente', ape_cliente + ' '+ nom_cliente 'Nombre Completo' , 
min(fecha) 'Primera venta', max(fecha)'Ultima venta', sum(cantidad*pre_unitario) 'Importe comprado'
from facturas as f join detalle_facturas as df on f.nro_factura = df.nro_factura
join clientes as c on c.cod_cliente = f.cod_cliente
group by c.cod_cliente, ape_cliente + ' '+ nom_cliente
order by ape_cliente + ' '+ nom_cliente


/*9. Se quiere saber el importe total vendido, la cantidad total vendida y el precio unitario
promedio por cliente y articulo, siempre que el nombre del cliente comience con letras qque van
de la a ala m . ordene por cliente, precio unitario promedio en forma descendente y articulo.
Rotule como IMPORTE TOTAL, CANTIDAD TOTAL, PRECIO PROMEDIO*/

select c.cod_cliente 'Codigo cliente' ,
sum(cantidad*pre_unitario) 'IMPORTE TOTAL' , sum(cantidad)'CANTIDAD TOTAL',
sum(cantidad*pre_unitario)/sum(cantidad) 'PRECIO PROMEDIO'
from clientes c join facturas f on c.cod_cliente=f.cod_cliente
join detalle_facturas df on df.nro_factura=f.nro_factura
where c.nom_cliente like '[A-M]%'
group by c.cod_cliente, df.cod_articulo
order by c.cod_cliente, [PRECIO PROMEDIO] desc


--10 --Se quiere saber la cantidad de facturas y la fecha la primer y última
--factura por vendedor y cliente, para números de factura que oscilan entre
--5 y 30. Ordene por vendedor, cantidad de ventas en forma descendente y
--cliente.

select f.cod_vendedor 'Cod Vendedor', nom_vendedor + ', '+ ape_vendedor 'Vendedor', f.cod_cliente 'Cod Cliente',
nom_cliente + ', '+ ape_cliente 'Cliente',
count(*) 'Cantidad de facturas',
min(f.fecha) 'Primera factura',
max(f.fecha) 'Ultima factura'
from facturas f join vendedores v on f.cod_cliente=v.cod_vendedor
join clientes c on f.cod_cliente=c.cod_cliente
where f.nro_factura between 5 and 30
group by f.cod_vendedor, f.cod_cliente, nom_cliente, nom_vendedor, ape_cliente, ape_vendedor
order by 1, 3 desc, 2