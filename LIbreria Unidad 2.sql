

-- cual es el precio promedio de los articulos
select avg(pre_unitario)
from articulos
where pre_unitario < 90


-- clientes que compraron este anio
select cod_cliente 'Codigo cliente', ape_cliente, nom_cliente
from clientes
where cod_cliente in (select cod_cliente from facturas where year(fecha) = year(getdate()))

--test de existencia
-- existen
select cod_cliente 'Codigo cliente', ape_cliente, nom_cliente
from clientes as c
where exists (select cod_cliente 
			  from facturas as f 
			  where year(fecha) = year(getdate()) 
			  and c.cod_cliente = f.cod_cliente
			  )

--listar los clientes que no vinieron este año y
-- que su apellido comience con A

select cod_cliente, nom_cliente, ape_cliente
from clientes as c
where not exists (select nro_factura
					from facturas as f
					where year(fecha) = year(getdate())
					and c.cod_cliente = f.cod_cliente
					)
and ape_cliente like 'a%'

--subconsultas

--1. Se solicita un listado de artículos cuyo precio es inferior al promedio de 
--precios de todos los artículos. (está resuelto en el material teórico)

select cod_articulo, descripcion, pre_unitario
from articulos
where pre_unitario < (select avg(pre_unitario) from articulos)

--2. Emitir un listado de los artículos que no fueron vendidos este año. En ese 
--listado solo incluir aquellos cuyo precio unitario del artículo oscile entre 
--50 y 100. 

select cod_articulo, descripcion, pre_unitario
from articulos as a
where cod_articulo not in (select cod_articulo
					from facturas as f join detalle_facturas as df
					on f.nro_factura = df.nro_factura
					where year(fecha) = year(getdate())
					)
and pre_unitario between 50 and 100

--3. Genere un reporte con los clientes que vinieron más de 2 veces el año 
--pasado. 

select cod_cliente, nom_cliente + ' ' + ape_cliente 'Cliente'
from clientes as c
where 2 < (select count(nro_factura)
			from facturas as f
			where f.cod_cliente = c.cod_cliente and 
			year(fecha) = year(getdate())-1  
			)

--4. Se quiere saber qué clientes no vinieron entre el 12/12/2015 y el 13/7/2020

select cod_cliente, nom_cliente + '' + ape_cliente 'Cliente'
from clientes as c
where not exists (select cod_cliente
					from facturas as f
					where c.cod_cliente = f.cod_cliente
					and fecha between '12/12/2015' and '13/07/2020'
					)
set dateformat dmy

--5. Listar los datos de las facturas de los clientes que solo vienen a comprar
--en febrero es decir que todas las veces que vienen a comprar haya sido
--en el mes de febrero (y no otro mes).

select nro_factura, format(fecha, 'dd/MM/yyyy')'Fecha', f.cod_cliente
from facturas f join clientes as c on f.cod_cliente = c.cod_cliente
where 2 = all (select month(fecha)
			      from facturas f1
			      where (f.cod_cliente = f1.cod_cliente) 
			  )


--6. Mostrar los datos de las facturas para los casos en que por año se hayan 
--hecho menos de 9 facturas.

select f.nro_factura 'Número de factura', format(fecha, 'yyyy-MM-dd') Fecha, nom_cliente + ' ' + ape_cliente 'Cliente',
nom_vendedor + ' ' + ape_vendedor 'Vendedor'
from facturas f join clientes c on c.cod_cliente=f.cod_cliente
join vendedores v on v.cod_vendedor=f.cod_vendedor
where year(fecha) in (select year(fecha) 
						from facturas 
						group by year(fecha) 
						having count(nro_factura)<9)
-- otra solucion

select f.nro_factura 'Número de factura', format(fecha, 'yyyy-MM-dd') Fecha, nom_cliente + ' ' + ape_cliente 'Cliente',
nom_vendedor + ' ' + ape_vendedor 'Vendedor'
from facturas f join clientes c on c.cod_cliente=f.cod_cliente
join vendedores v on v.cod_vendedor=f.cod_vendedor
where 9 > (select count(*) 
			from facturas f1 
			where year(f.fecha) = year(f1.fecha)
			)


--7. Emitir un reporte con las facturas cuyo importe total haya sido superior a 
--1.500 (incluir en el reporte los datos de los artículos vendidos y los 
--importes). 

select f.nro_factura, FORMAT(fecha, 'dd/MM/yyyy')'Fecha',
sum(cantidad * pre_unitario) 'Importe'
from facturas f join detalle_facturas df on df.nro_factura = f.nro_factura
where 1500 < (select sum(cantidad * pre_unitario)
			from detalle_facturas as d1
			where d1.nro_factura = f.nro_factura
			)
group by f.nro_factura, fecha


--8. Se quiere saber qué vendedores nunca atendieron a estos clientes: 1 y 6.
--Muestre solamente el nombre del vendedor.

select ape_vendedor+' '+nom_vendedor Vendedor,
calle+' '+cast(altura as varchar) Direccion,
nro_tel Telefono, [e-mail] Email
from vendedores v
where not exists(select nro_factura 
				from facturas 
				where cod_vendedor = v.cod_vendedor and 
				cod_cliente in (1,6))

--9. Listar los datos de los artículos que superaron el promedio del Importe de 
--ventas de $ 1.000. 

select descripcion, pre_unitario, stock_minimo
from articulos as a
where 1000 < (select avg(cantidad*pre_unitario)
				from detalle_facturas df
				where a.cod_articulo = df.cod_articulo
				)

--10. ¿Qué artículos nunca se vendieron? Tenga además en cuenta que su 
--nombre comience con letras que van de la “d” a la “p”. Muestre solamente 
--la descripción del artículo. 

select descripcion
from articulos as a
where not exists (select cod_articulo
				from detalle_facturas as df
				where df.cod_articulo = a.cod_articulo
				)
and descripcion like '[d-p]%'

--11. Listar número de factura, fecha y cliente para los casos en que ese cliente 
--haya sido atendido alguna vez por el vendedor de código 3.

select nro_factura,fecha,c.cod_cliente,ape_cliente+', '+nom_cliente Cliente
from facturas as f join clientes as c on f.cod_cliente=c.cod_cliente
where 3 = any (select cod_vendedor
				from vendedores as v
				where v.cod_vendedor=f.cod_vendedor)

--12. Listar número de factura, fecha, artículo, cantidad e importe para los 
--casos en que todas las cantidades (de unidades vendidas de cada 
--artículo) de esa factura sean superiores a 40.

select f.nro_factura, fecha, descripcion, cantidad
from facturas as f join detalle_facturas as df on f.nro_factura = df.nro_factura
join articulos as a on a.cod_articulo = df.cod_articulo
where 40 < all(select cantidad
				from detalle_facturas d1
				where d1.nro_factura = f.nro_factura
				)

--13. Emitir un listado que muestre número de factura, fecha, artículo, cantidad 
--e importe; para los casos en que la cantidad total de unidades vendidas 
--sean superior a 80.

select f.nro_factura, fecha, descripcion, cantidad, cantidad*df.pre_unitario 'Importe'
from facturas as f join detalle_facturas as df on f.nro_factura = df.nro_factura
join articulos as a on a.cod_articulo = df.cod_articulo
where 80 < (select sum(cantidad)
			from detalle_facturas d1
			where d1.nro_factura = f.nro_factura
			)

--14. Realizar un listado de número de factura, fecha, cliente, artículo e importe 
--para los casos en que al menos uno de los importes de esa factura sea 
--menor a 3.000.

select f.nro_factura, fecha, descripcion, cantidad, cantidad*df.pre_unitario 'Importe'
from facturas as f join detalle_facturas as df on f.nro_factura = df.nro_factura
join articulos as a on a.cod_articulo = df.cod_articulo
where 3000 > any (select (cantidad*pre_unitario)
					from detalle_facturas d1
					where d1.nro_factura = f.nro_factura
					)

-- SubConsultas con el Having

--1. Se quiere saber ¿cuándo realizó su primer venta cada vendedor? y 
--¿cuánto fue el importe total de las ventas que ha realizado? Mostrar estos 
--datos en un listado solo para los casos en que su importe promedio de 
--vendido sea superior al importe promedio general (importe promedio de 
--todas las facturas). 

select v.cod_vendedor, nom_vendedor + ' ' + ape_vendedor 'Vendedor',
sum(cantidad*pre_unitario) 'Importe Total', min(fecha) 'Primer Venta'
from vendedores as v join facturas as f on v.cod_vendedor = f.cod_vendedor
join detalle_facturas as df on df.nro_factura = f.nro_factura
group by v.cod_vendedor,nom_vendedor + ' ' + ape_vendedor
having sum(cantidad*pre_unitario)/count(distinct f.nro_factura) > 
					(select sum(cantidad*pre_unitario/count(distinct nro_factura)
					from detalle_facturas )
					)
--2. Liste los montos totales mensuales facturados por cliente y además del 
--promedio de ese monto y el promedio de precio de artículos Todos esto 
--datos correspondientes a período que va desde el 1° de febrero al 30 de 
--agosto del 2014. Sólo muestre los datos si esos montos totales son
--superiores o iguales al promedio global. 


--3. Por cada artículo que se tiene a la venta, se quiere saber el importe 
--promedio vendido, la cantidad total vendida por artículo, para los casos 
--en que los números de factura no sean uno de los siguientes: 2, 10, 7, 13, 
--22 y que ese importe promedio sea inferior al importe promedio de ese 
--artículo. 
select df.cod_articulo, sum(cantidad*df.pre_unitario)/count(distinct f.nro_factura) 'Promedio',
sum(cantidad) 'Cant. Total Vendida'
from facturas as f join detalle_facturas as df on f.nro_factura = df.nro_factura
join articulos as a on a.cod_articulo = df.cod_articulo
where f.nro_factura not in (2,10,7,13)
group by df.cod_articulo
having sum(cantidad*df.pre_unitario)/count(distinct f.nro_factura) <
			(select sum(cantidad*pre_unitario)/count(distinct f.nro_factura)
			from detalle_facturas d1
			where  d1.cod_articulo = df.cod_articulo
			)
--4. Listar la cantidad total vendida, el importe y promedio vendido por fecha, 
--siempre que esa cantidad sea superior al promedio de la cantidad global. 
--Rotule y ordene. 

select fecha, sum(cantidad) 'Cant. total Vendida', sum(cantidad*df.pre_unitario) 'Importe',
sum(cantidad*df.pre_unitario)/count(distinct f.nro_factura) 'Importe Promedio'
from facturas f join detalle_facturas df on f.nro_factura = df.nro_factura
group by fecha
having sum(cantidad) > (select avg(cantidad)
						from detalle_facturas )

--5. Se quiere saber el promedio del importe vendido y la fecha de la primer 
--venta por fecha y artículo para los casos en que las cantidades vendidas 
--oscilen entre 5 y 20 y que ese importe sea superior al importe promedio 
--de ese artículo. 

select fecha, cod_articulo, sum(cantidad*pre_unitario)/count(distinct f.nro_factura) 'Imp. Promedio',
min(fecha) 'Primer venta'
from facturas f join detalle_facturas df on f.nro_factura = df.nro_factura
where cantidad between 5 and 20
group by fecha, cod_articulo
having sum(cantidad*pre_unitario)/count(distinct f.nro_factura) > 
			(select sum(cantidad*d1.pre_unitario)/count(distinct d1.nro_factura)
			from detalle_facturas d1				
			where d1.cod_articulo = df.cod_articulo
			)

--6. Emita un listado con los montos diarios facturados que sean inferior al 
--importe promedio general. 




--7. Se quiere saber la fecha de la primera y última venta, el importe total 
--facturado por cliente para los años que oscilen entre el 2010 y 2015 y que 
--el importe promedio facturado sea menor que el importe promedio total 
--para ese cliente. 


--8. Realice un informe que muestre cuánto fue el total anual facturado por 
--cada vendedor, para los casos en que el nombre de vendedor no comience 
--con ‘B’ ni con ‘M’, que los números de facturas oscilen entre 5 y 25 y que 
--el promedio del monto facturado sea inferior al promedio de ese año.