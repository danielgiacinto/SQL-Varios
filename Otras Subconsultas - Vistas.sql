-- listar los datos articulos y la diferencie entre su precio y el precio del articulo mas caro

select descripcion, pre_unitario, (select max(pre_unitario) from articulos)-pre_unitario 'Diferencia del precio'
from articulos

-- listar los articulos descripcion, precio y el promedio de los precios al que fue vendido ese
-- articulo

select cod_articulo, descripcion, pre_unitario, 
			(select avg(pre_unitario) 
			from detalle_facturas
			where cod_articulo = a.cod_articulo) 'Promedio simple precio venta',
			(select sum(pre_unitario*cantidad)/sum(cantidad) 
			from detalle_facturas
			where cod_articulo = a.cod_articulo) 'Promedio ponderado precio venta'
from articulos a

-- listar los datos de la factura del año en curso mostrando ademas el total
-- sin mostrar los detalles

SELECT f.nro_factura, fecha, ape_cliente +' '+ nom_cliente 'Cliente',
 f2.total
 FROM facturas f JOIN clientes c ON c.cod_cliente = f.cod_cliente
 JOIN (SELECT nro_factura, SUM(pre_unitario*cantidad) 'total' 
 FROM detalle_facturas d join facturas ff on d.nro_factura = ff.nro_factura
 where year(fecha)=year(getdate())
 GROUP BY d.nro_factura) AS f2 ON f2.nro_factura = f.nro_factura
WHERE YEAR(fecha)= YEAR(GETDATE())

-- PROBLEMAS 2.3 OTRAS SUBCONSULTAS

---- 1. Se quiere listar el precio de los artículos y la diferencia de éste con el precio 
--del artículo más caro:

select descripcion, pre_unitario 'Precio de los articulos', (select max(pre_unitario)
															from detalle_facturas d)
															- pre_unitario 'Diferencia con el mas caro'
															
from articulos a

----2. Listar el precio actual de los artículos y el precio histórico vendido más 
--barato

select descripcion, pre_unitario, (select min(pre_unitario) 
								from detalle_facturas d
								where d.cod_articulo = a.cod_articulo) 'Precio vta mas barato'
from articulos a

--3. Se quiere emitir un listado de las facturas del año en curso detallando 
--número de factura, cliente, fecha y total de la misma.

select df.nro_factura as 'num de factura',
 c.nom_cliente +'-'+c.ape_cliente as 'Nom cliente',
 str(day(f.fecha))+''+str(month(f.fecha))+''+str(year(f.fecha)) as
'fecha',
 sum(df.pre_unitario*df.cantidad) as 'total'
from facturas f inner join detalle_facturas df on df.nro_factura =
f.nro_factura
 inner join clientes c on c.cod_cliente = f.cod_cliente
where year(f.fecha) = year(GETDATE())
group by df.nro_factura, c.nom_cliente, c.ape_cliente, f.fecha

--5. Generar un reporte un listado con la código y descripción de los artículos 
--su precio actual, el precio más barato y el más caro al que se vendió hace 
--5 años.

select cod_articulo, descripcion, pre_unitario, 
					(select min(pre_unitario)from detalle_facturas d 
					join facturas f on d.nro_factura = f.nro_factura
					where year(fecha)=year(getdate())-5
					and d.cod_articulo = a.cod_articulo) as 'Menor precio',
					(select max(pre_unitario)from detalle_facturas d 
					join facturas f on d.nro_factura = f.nro_factura
					where year(fecha)=year(getdate())-5
					and d.cod_articulo = a.cod_articulo) as 'Mayor precio'
from articulos a

--6. Descontar un 3,5% los precios de los artículos que se vendieron menos de 
--5 unidades los últimos 3 meses.

update articulos
set pre_unitario = pre_unitario*0.965
where 5 > (select SUM(cantidad)
from detalle_facturas d join facturas f on f.nro_factura=d.nro_factura
where articulos.cod_articulo = d.cod_articulo
and DATEDIFF(month, fecha, getdate())<3 )

--7. Se quiere eliminar los clientes que no vinieron nunca. 
--// NO EJECUTAR BORRA TODO

delete from clientes
where cod_cliente not in (select cod_cliente
							from facturas)

--8. Eliminar los clientes que hace más de 10 años que no vienen
--// NO EJECUTAR BORRA TODO

delete from clientes
where cod_cliente not in (select cod_cliente
							from facturas
							where year(getdate()-year(fecha))>=10)

-- UNIDAD 3 VISTASS

--crear una vista que los datos de las facturas con sus totales 
-- (los totales facturados por factura y fecha)

alter view vis_facturacion
as
select f.nro_factura nro, fecha, sum(cantidad*pre_unitario) 'Total', 
avg(cantidad)'Prom'
from facturas f join detalle_facturas d  on f.nro_factura = d.nro_factura
where year(fecha) = year(getdate())
group by f.nro_factura, fecha

-- consultar nro de factura, y total facturado desde la vista anterior 
-- con las facturas de los utlimos 5 meses y el promedio de la cantidad es mayor a 10

select nro, Total, Prom
from vis_facturacion
where datediff(month,fecha,getdate())<5
and Prom > 10

--2. Cree una vista que liste la fecha, la factura, el código y nombre del vendedor, el 
--artículo, la cantidad e importe, para lo que va del año. Rotule como FECHA, 
--NRO_FACTURA, CODIGO_VENDEDOR, NOMBRE_VENDEDOR, ARTICULO, 
--CANTIDAD, IMPORTE.

create view vis_vendedor
as
select f.nro_factura as nro_factura, v.cod_vendedor as cod_vendedor, nom_vendedor + ' ' + ape_vendedor as Vendedor, 
fecha as Fecha, a.descripcion as articulo, sum(df.cantidad) as cantidad, sum(df.cantidad*df.pre_unitario) as Importe 
from facturas f join detalle_facturas df on f.nro_factura = df.nro_factura
join vendedores v on v.cod_vendedor = f.cod_vendedor
join articulos a on a.cod_articulo = df.cod_articulo
group by f.nro_factura, v.cod_vendedor, nom_vendedor + ' ' + ape_vendedor, fecha, a.descripcion

select *
from vis_vendedor
where YEAR(fecha) = year(getdate())

--3. Modifique la vista creada en el punto anterior, agréguele la condición de que 
--solo tome el mes pasado (mes anterior al actual) y que también muestre la 
--dirección del vendedor.

alter view vis_vendedor
as
select f.nro_factura as nro_factura, v.cod_vendedor as cod_vendedor, nom_vendedor + ' ' + ape_vendedor as Vendedor, 
fecha as Fecha, a.descripcion as articulo, sum(df.cantidad) as cantidad, sum(df.cantidad*df.pre_unitario) as Importe,
b.barrio Direccion
from facturas f join detalle_facturas df on f.nro_factura = df.nro_factura
join vendedores v on v.cod_vendedor = f.cod_vendedor
join articulos a on a.cod_articulo = df.cod_articulo
join barrios b on b.cod_barrio = v.cod_barrio
group by f.nro_factura, v.cod_vendedor, nom_vendedor + ' ' + ape_vendedor, fecha, a.descripcion, b.barrio

select * 
from vis_vendedor
where datediff(month, fecha, getdate())= 1 -- no hay registros

--4. Consulta las vistas según el siguiente detalle:
--a. Llame a la vista creada en el punto anterior pero filtrando por importes 
--inferiores a $120.

select nro_factura, Vendedor, Importe, cantidad
from vis_vendedor
where Importe < 120
--b. Llame a la vista creada en el punto anterior filtrando para el vendedor 
--Miranda.

select *
from vis_vendedor
where Vendedor = 'Marcelo Miranda'
--c. Llama a la vista creada en el punto 4 filtrando para los importes 
--menores a 10.000.

select *
from vis_vendedor
where Importe < 10000

-- 3.2 Procedimientos almacenados ----------------------------------

create procedure pa_articulos_precio
@precio money
as
select * from articulos
where pre_unitario < @precio

execute pa_articulos_precio 100
--------------------------------------------------------------------
create procedure pa_articulos_between
@precio1 money,
@precio2 money
as
select * from articulos
where pre_unitario between @precio1 and @precio2

execute pa_articulos_between 100, 500

create procedure ventas_articulos
@codigo int,
@total decimal(10,2) output,
@precioProm decimal(10,2) output
as
select descripcion from articulos
where cod_articulo = @codigo
select @total=sum(cantidad*pre_unitario)
from detalle_facturas
where cod_articulo = @codigo
select @precioProm = sum(pre_unitario)/sum(cantidad)
from detalle_facturas
where cod_articulo = @codigo

declare @total decimal(10,2)
declare @precioProm decimal(10,2)
execute ventas_articulos 3, @total output, @precioProm output
select @total 'Total', @precioProm 'Promedio'

create procedure pe_articulos_precios
@precio decimal(12,2) = null
as
if @precio is null
begin
select 'Debe indicar un precio'
return
end;
select descripcion from articulos
where pre_unitario < @precio

execute pe_articulos_precios 200

------- procedimiento para ingresar articulos
create procedure pa_articulos_ingreso
@descripcion nvarchar (50) NULL ,
@stock_minimo smallint NULL ,
@stock smallint null,
@pre_unitario decimal(10, 2) ,
@observaciones nvarchar (50)=null
as 
if (@pre_unitario is null)
 return 0
else 
begin
insert into articulos 
values(@descripcion,@stock_minimo,@stock, @pre_unitario,@observaciones)
 return 1
end;

execute pa_articulos_ingreso 'fibron', 5, 25, 200

--1. Cree los siguientes SP:
--a. Detalle_Ventas: liste la fecha, la factura, el vendedor, el cliente, el 
--artículo, cantidad e importe. Este SP recibirá como parámetros de E un 
--rango de fechas.
select * from detalle_facturas
-- a
Alter procedure sp_detalle_ventas
@fecha1 datetime,
@fecha2 datetime
as
select f.nro_factura, fecha, nom_cliente + ' ' + ape_cliente 'Cliente', nom_vendedor + ' ' + ape_vendedor 'vendedor',
descripcion 'Articulo', sum(cantidad*df.pre_unitario) 'Importe', sum(cantidad) 'Cantidad'
from facturas f join detalle_facturas df on f.nro_factura = df.nro_factura
join clientes c on c.cod_cliente = f.cod_cliente
join vendedores v on v.cod_vendedor = f.cod_vendedor
join articulos a on a.cod_articulo = df.cod_articulo
where fecha between @fecha1 and @fecha2
group by f.nro_factura, fecha, nom_cliente + '' + ape_cliente, nom_vendedor + '' + ape_vendedor, descripcion


execute sp_detalle_ventas '02/05/2005', '02/05/2010'

--b. CantidadArt_Cli : este SP me debe devolver la cantidad de artículos o 
--clientes (según se pida) que existen en la empresa.

Alter procedure sp_cantidadArt_Cli
@cant_cliente varchar(50) null,
@cant_articulo varchar(50) null
as
if (@cant_cliente = 'si')
select count(cod_cliente) 'Cantidad de Clientes' from clientes
if (@cant_articulo = 'si')
select count(cod_articulo) 'Cantidad de Articulos' from articulos

execute sp_cantidadArt_Cli 'si', 'si'

--c. INS_Vendedor: Cree un SP que le permita insertar registros en la tabla 
--vendedores.

create procedure sp_insert_vendedores
@nom_vendedor nvarchar(50),
@ape_vendedor nvarchar(50),
@calle nvarchar(50),
@altura int,
@cod_barrio int,
@nro_tel bigint null,
@email nvarchar(50) null,
@fec_nac smalldatetime null
as
if (@nom_vendedor is null or @ape_vendedor is null)
	return 0;
else
insert into vendedores values (@nom_vendedor, @ape_vendedor, @calle, @altura, @cod_barrio, @nro_tel, @email,@fec_nac)
	return 1;

execute sp_insert_vendedores 'Daniel', 'Giacinto', 'Rondeau', 212, 10, 3534067588, 'danielgiacinto@gmail.com', '06/08/2001' 

select * from barrios
select * from vendedores

--d. UPD_Vendedor: cree un SP que le permita modificar un vendedor 
--cargado.


Alter procedure sp_update_vendedores
@cod_vendedor int,
@nom_vendedor nvarchar(50) ,
@ape_vendedor nvarchar(50) ,
@calle nvarchar(50) ,
@altura int ,
@cod_barrio int ,
@nro_tel bigint ,
@email nvarchar(50) ,
@fec_nac smalldatetime 
as
if (@nom_vendedor is null or @ape_vendedor is null)
	return 0;
else
update vendedores
set nom_vendedor = @nom_vendedor,
	ape_vendedor = @ape_vendedor,
	calle = @calle,
	altura = @altura,
	cod_barrio = @cod_barrio,
	nro_tel = @nro_tel,
	[e-mail] = @email,
	fec_nac = @fec_nac
where cod_vendedor = @cod_vendedor
	return 1;

execute sp_update_vendedores 7, 'Daniel', 'Giacinto', 'Ituzaingo', 512, 10, 3534067588, 'danielgiacinto@gmail.com', '06/08/2001'
select * from vendedores

--e. DEL_Vendedor: cree un SP que le permita eliminar un vendedor 
--ingresado.

Alter procedure sp_delete_vendedor
@cod_vendedor int
as
if (@cod_vendedor = 0)
	return 0;
else
delete vendedores
where cod_vendedor = @cod_vendedor
	return 1;

execute sp_delete_vendedor 20

--2. Modifique el SP 1-a, permitiendo que los resultados del SP puedan filtrarse por 
--una fecha determinada, por un rango de fechas y por un rango de vendedores; 
--según se pida.

Alter procedure sp_detalle_ventas
@fecha1 datetime,
@fecha2 datetime
as
select f.nro_factura, fecha, nom_cliente + ' ' + ape_cliente 'Cliente', nom_vendedor + ' ' + ape_vendedor 'vendedor',
descripcion 'Articulo', sum(cantidad*df.pre_unitario) 'Importe', sum(cantidad) 'Cantidad'
from facturas f join detalle_facturas df on f.nro_factura = df.nro_factura
join clientes c on c.cod_cliente = f.cod_cliente
join vendedores v on v.cod_vendedor = f.cod_vendedor
join articulos a on a.cod_articulo = df.cod_articulo
where fecha between @fecha1 and @fecha2
group by f.nro_factura, fecha, nom_cliente + '' + ape_cliente, nom_vendedor + '' + ape_vendedor, descripcion


-- Problema 3.3 Funciones definidas por el usuario

create function f_promedio
(
@valor1 decimal(4,2),
@valor2 decimal(4,2)
)
returns decimal(6,2)
as
begin
declare @resultado decimal(6,2)
set @resultado = (@valor1+@valor2)/2
return @resultado
end;

select dbo.f_promedio(10, 8) -- devuelve el promedio de los valores

-------------------------
create function f_nombreMes
(@fecha datetime = '01/01/2007')
returns varchar(50)
as
begin
declare @nombre varchar(50)
set @nombre =
	case datename(month, @fecha)
	when 'January' then 'Enero'
	when 'Febraury' then 'Febrero'
	when 'March' then 'Marzo'
	when 'April' then 'Abril'
	when 'May' then 'Mayo'
	when 'June' then 'Junio'
	when 'July' then 'Julio'
	when 'August' then 'Agosto'
	when 'September' then 'Septiembre'
	when 'October' then 'Octubre'
	when 'November' then 'Noviembre'
	when 'December' then 'Diciembre'
	end--case
return @nombre
end;

select dbo.f_nombreMes ('02/08/2005')

-----------------------------------------------------
alter function f_ofertas
(@minimo decimal(5,2))
returns @ofertas table 
(cod_articulo int,
descripcion varchar(100),
pre_unitario money,
observaciones varchar(100)
)
as
	begin
	insert @ofertas
	select cod_articulo, descripcion, pre_unitario, observaciones
	from articulos
	where pre_unitario < @minimo
	return
	end;

select * from articulos a join dbo.f_ofertas(200) as f on a.cod_articulo = f.cod_articulo

-------------------------------------------

alter function f_articulos
(@descrip varchar(100) = 'Lapiz')
returns table
as
return (select cod_articulo, descripcion, pre_unitario
		from articulos
		where descripcion like '%' + @descrip + '%'
		);

select * from articulos as a join dbo.f_articulos('Papel') as f on a.cod_articulo = f.cod_articulo


--5. Cree las siguientes funciones:
--a. Hora: una función que les devuelva la hora del sistema en el formato 
--HH:MM:SS (tipo carácter de 8).

create function f_hora
()
returns varchar(8)
as
	select hour(getdate()) 'HH', minute(getdate()) 'MM', second(getdate()) 'SS'

select CURRENT_TIMESTAMP

select minute(GETDATE())
select Getdate()


--b. Fecha: una función que devuelva la fecha en el formato AAAMMDD (en 
--carácter de 8), a partir de una fecha que le ingresa como parámetro 
--(ingresa como tipo fecha).

--c. Dia_Habil: función que devuelve si un día es o no hábil (considere 
--como días no hábiles los sábados y domingos). Debe devolver 1 
--(hábil), 0 (no hábil)

create function f_dia_habil
(@dia varchar(20))
returns int
as
begin
if

--6. Modifique la f(x) 1.c, considerando solo como día no hábil el domingo.
--7. Ejecute las funciones creadas en el punto 1 (todas).
--8. Elimine las funciones creadas en el punto 1.




