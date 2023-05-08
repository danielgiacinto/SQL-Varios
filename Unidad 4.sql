-- Unidad 4
-- ejemplo de manejo de errores
-- capturar el error de division por cero

begin try
	select 15/0 as error;
end try
begin catch
	select 'Se produjo el siguiente error' as Mensaje,
	error_number() as Numero,
	error_state() as Estado,
	error_severity() as Gravedad,
	error_procedure() as Procedimiento,
	error_line() as Linea,
	error_message() as Mensaje;
end catch;


begin try
	select 15/0 as error;
end try
begin catch
	Print 'No se puede dividir por cero'
end catch;

-- muestra todos los mensajes de error -- ejecutar en master
select *, len(description) from master.dbo.sysmessages
where error = 8134

----------------------------------------------
-- Triggers
-- si se quiere controlar que en una venta la cantidada vendida
-- al hacer la venta se resta el stock de la tabla articulos

create trigger dis_ventas_insertar
on detalle_facturas
for insert
as
	declare @stk int, @cod int, @cant int
	set @cant = (select cantidad from inserted)
	set @cod= (select cod_articulo from inserted)
	set @stk = (select stock from articulos as a
					where cod_articulo=@cod)
	if @stk >= @cant
		begin
			update articulos 
			set stock = stock-@cant
			from articulos
			where cod_articulo = @cod
			print 'Venta realizada'
		end
	else
		begin
		raiserror ('El stock en articulos es menor que la cantidad solicitada', 16, 1)
		rollback transaction
		end;


insert into facturas values (getdate(), 5, 3)
insert into Detalle_facturas values (571, 6, 6, 6)

select * from articulos
select * from detalle_facturas order by nro_factura desc
select * from facturas order by nro_factura desc



create trigger dis_articulos_actualizar_precio
on articulos
for update
as
	if update(pre_unitario)
		begin
			raiserror('No se puede modificar el precio de un articulo', 10, 1)
			rollback transaction
		end
	else
		print 'La actualizacion se realizo'

-- aca probar el trigger dis_articulos_actulizar_precio
update articulos
set pre_unitario = 10
where cod_articulo = 2

--4.1: Introducción a la Programación en SQL Server

--1. Declarar 3 variables que se llamen codigo, stock y stockMinimo 
--respectivamente. A la variable codigo setearle un valor. Las variables stock y 
--stockMinimo almacenarán el resultado de las columnas de la tabla artículos 
--stock y stockMinimo respectivamente filtradas por el código que se 
--corresponda con la variable codigo.

declare @codigo int, @stock int, @stockMinimo int
set @codigo = 1
select @stock=stock, @stockMinimo=stock_minimo
from articulos
where cod_articulo = @codigo
select @stock 'Stock', @stockMinimo 'Stock minimo'

--2. Utilizando el punto anterior, verificar si la variable stock o stockMinimo tienen 
--algún valor. Mostrar un mensaje indicando si es necesario realizar reposición 
--de artículos o no.
declare @codigo int, @stock int, @stockMinimo int
set @codigo = 4
select @stock=stock, @stockMinimo=stock_minimo
from articulos
where cod_articulo = @codigo
if @stock is null or @stockMinimo is null
	print 'No hay datos suficientes'
else
	if @stock-@stockMinimo <= 0
		print 'Es necesario hacer reposicion del articulo: ' + trim(str(@codigo))
	else
		print 'Hay suficiente stock del articulo: ' + trim(str(@codigo))

--3. Modificar el ejercicio 1 agregando una variable más donde se almacene el 
--precio del artículo. En caso que el precio sea menor a $500, aplicarle un 
--incremento del 10%. En caso de que el precio sea mayor a $500 notificar dicha 
--situación y mostrar el precio del artículo.
declare @cod int,  @precio money
set @cod = 4
select @precio=pre_unitario
from articulos
where cod_articulo=@cod
	if @precio < 500
		begin	
			update articulos
			set pre_unitario = pre_unitario*1.10
			where cod_articulo = @cod
			print 'Se actualizo el precio'
		end
	else
		select @cod as codigo, @precio as pre_unitario, 'No es necesario modificar el precio' as observaciones

select * from articulos
--4. Declarar dos variables enteras, y mostrar la suma de todos los números 
--comprendidos entre ellos. En caso de ser ambos números iguales mostrar un 
--mensaje informando dicha situación
declare @n1 int, @n2 int, @resultado int
set @n1 = 1
set @n2 = 4
set @resultado = 0
if @n1 = @n2
	print 'Los numeros no pueden ser iguales'
else
	if @n1 >= @n2
		print 'El primer numero no puede ser mas grande que el segundo'
	else
		begin
		while @n1 <= @n2
			begin
				set @resultado = @resultado + @n1
				set @n1 = @n1 + 1
			end
		end
	select @resultado as Suma

	
--5. Mostrar nombre y precio de todos los artículos. Mostrar en una tercer columna 
--la leyenda ‘Muy caro’ para precios mayores a $500, ‘Accesible’ para precios 
--entre $300 y $500, ‘Barato’ para precios entre $100 y $300 y ‘Regalado’ para 
--precios menores a $100.
select descripcion, pre_unitario, mensaje = 
	case
		when pre_unitario >500 then 'Muy Caro'
		when pre_unitario between 300 and 500 then 'Accesible'
		when pre_unitario between 100 and 300 then 'Barato'
		when pre_unitario < 100 then 'Regalado'
	end
from articulos

--6. Modificar el punto 2 reemplazando el mensaje de que es necesario reponer 
--artículos por una excepción.

declare @codigo int, @stock int, @stockMinimo int
set @codigo = 3
select @stock=stock, @stockMinimo=stock_minimo
from articulos
where cod_articulo = @codigo
if @stock is null or @stockMinimo is null
	raiserror ('Hay valores nulos', 11,1)
else
	if @stock <= @stockMinimo
		raiserror ('Hay que reponer Stock', 10,1)
	else
		raiserror ('No hay que reponer Stock', 10,1)

select * from articulos

--4.2: Manejo de errores
--1. Modificar el ejercicio 2 de la sección 1.1 reemplazando los mensajes
--mostrados en consola con print, por excepciones. Verificar el comportamiento 
--en el SQL Server Management.
declare @codigo int, @stock int, @stockMinimo int
set @codigo = 1
select @stock=stock, @stockMinimo=stock_minimo
from articulos
where cod_articulo = @codigo
if @stock is null or @stockMinimo is null
	begin try
		s
	end try
	begin catch
			select 'Los valores son nulos' as Mensaje,
		error_number() as Numero,
		error_state() as Estado,
		error_severity() as Gravedad,
		error_procedure() as Procedimiento,
		error_line() as Linea,
		error_message() as Mensaje;
	end catch
else
	if @stock-@stockMinimo <= 0
		print 'Es necesario hacer reposicion del articulo: ' + trim(str(@codigo))
	else
		print 'Hay suficiente stock del articulo: ' + trim(str(@codigo))

--2. Modificar el ejercicio anterior agregando las cláusulas de try catch para 
--manejo de errores, y mostrar el mensaje capturado en la excepción con print. 







--4.3: Programación aplicada a Procedimientos Almacenados y Funciones 
--definidas por el usuario

--1. Programar procedimientos almacenados que permitan realizar las siguientes 
--tareas:
--a. Mostrar los artículos cuyo precio sea mayor o igual que un valor que se 
--envía por parámetro.
create procedure sp_articulo_1
@valor int
as
select descripcion, pre_unitario
from articulos
where pre_unitario >= @valor

execute sp_articulo_1 200

--b. Ingresar un artículo nuevo, verificando que la cantidad de stock que se 
--pasa por parámetro sea un valor mayor a 30 unidades y menor que 100. 
--Informar un error caso contrario.
create procedure sp_insert_articulo_stock
@descripcion varchar(50)=null,
@stock int=null,
@pre_unitario money=null
as
if @stock > 30 and @stock < 100
	begin
		insert into articulos (descripcion, stock, pre_unitario) values (@descripcion, @stock, @pre_unitario)
		print 'Se inserto con exito el articulo'
	end
else
	print 'Por favor verificar las condiciones del stock'

execute sp_insert_articulo_stock 'Goma de borrar', 50, 150

select * from articulos
--c. Mostrar un mensaje informativo acerca de si hay que reponer o no 
--stock de un artículo cuyo código sea enviado por parámetro

create procedure sp_reponer_articulo
@cod int
as
declare @valor int
declare @descripcion varchar(50)
select @valor=stock-stock_minimo, @descripcion=descripcion
from articulos
where cod_articulo = @cod
if @valor <= 0
	select @cod as Codigo, @descripcion as descripcion, 'Reponer Stock' as Mensaje
else
	select @cod as Codigo, @descripcion as descripcion, 'Stock ok' as Mensaje

execute sp_reponer_articulo 1
select * from articulos

--d. Actualizar el precio de los productos que tengan un precio menor a uno 
--ingresado por parámetro en un porcentaje que también se envíe por 
--parámetro. Si no se modifica ningún elemento informar dicha situación
select * from articulos

create procedure sp_productos_update
@porcentaje decimal(5,2),
@precio money
as
if @porcentaje is null or @precio is null
	select 'Alguno de los valores son nulos' as Mensaje
else
	begin
		update articulos
		set pre_unitario = pre_unitario*(1+@porcentaje/100)
		where pre_unitario < @precio
		select 'Se actualizaron los precios' as Mensaje
	end

select * from articulos
execute sp_productos_update 15, 100
--e. Mostrar el nombre del cliente al que se le realizó la primer venta en un 
--parámetro de salida.

create procedure sp_nom_cliente
@cod int output
as
select top 1 @cod=cod_cliente
from facturas
order by fecha

declare @c int
execute sp_nom_cliente @c output
select @c as '1er Cliente'
---------------------------------------
alter procedure sp_nom_cliente_apellido
@cod int output,
@nom varchar(50) output,
@ape varchar(50) output
as
select top 1 @cod=c.cod_cliente, @nom=nom_cliente, @ape=ape_cliente
from facturas as f join clientes as c on f.cod_cliente = c.cod_cliente
order by fecha 

declare @c int, @n varchar(50), @a varchar(50)
execute sp_nom_cliente_apellido @c output, @n output, @a output
select @c as Codigo, @n + ' ' + @a as Cliente, 'Primer Cliente' as Observacion

--f. Realizar un select que busque el artículo cuyo nombre empiece con un 
--valor enviado por parámetro y almacenar su nombre en un parámetro 
--de salida. En caso que haya varios artículos ocurrirá una excepción 
--que deberá ser manejada con try catch.

create procedure sp_buscar_articulo
@nom_ent varchar(10),
@nom_salida varchar(150) output
as
begin try
	set @nom_salida = (select descripcion
					from articulos
					where descripcion like @nom_ent)
end try
begin catch
	select ERROR_NUMBER() as 'Nro. error', ERROR_MESSAGE() as Error
end catch

declare @salida varchar(150)
execute sp_buscar_articulo 'C%', @salida output
select @salida as 'Articulo'

--2. Programar funciones que permitan realizar las siguientes tareas:
--a. Devolver una cadena de caracteres compuesto por los siguientes 
--datos: Apellido, Nombre, Telefono, Calle, Altura y Nombre del Barrio, 
--de un determinado cliente, que se puede informar por codigo de cliente 
--o email.

alter function f_cadena
(@cod int=null, @mail varchar(50)=null )
returns varchar(400)
as
begin
	declare @cadena varchar(400)
	if @cod is null or @mail is not null
		set @cadena = (select ape_cliente+' '+nom_cliente+' Tel. '+trim(str(nro_tel))+' calle '+calle+' '+trim(str(altura))+' B° '+barrio
		from clientes c join barrios b on c.cod_barrio = b.cod_barrio
		where [e-mail] like @mail)
	else
		if @cod is not null or @mail is null
			set @cadena = (select ape_cliente+' '+nom_cliente+' Tel. '+' calle '+calle+' '+trim(str(altura))+' B° '+barrio
			from clientes c join barrios b on c.cod_barrio = b.cod_barrio
			where cod_cliente like @cod)
		else
			if @cod is not null and @mail is not null
				set @cadena = (select ape_cliente+' '+nom_cliente+' Tel.'+' calle '+calle+' '+trim(str(altura))+' B° '+barrio
				from clientes c join barrios b on c.cod_barrio = b.cod_barrio
				where cod_cliente like @cod and [e-mail] like @mail)
			else
				set @cadena = 'Debe proporcionar algun dato'
	return @cadena
end
select * from clientes
select dbo.f_cadena(4, default)

--b. Devolver todos los artículos, se envía un parámetro que permite 
--ordenar el resultado por el campo precio de manera ascendente (‘A’), o 
--descendente (‘D’).
create procedure sp_order
@order varchar(50)='A'
as
begin
	if @order = 'A'
		select cod_articulo, descripcion, pre_unitario  from articulos
		order by pre_unitario asc
	else
		select cod_articulo, descripcion, pre_unitario from articulos
		order by pre_unitario desc
end

execute sp_order 'A'

--c. Crear una función que devuelva el precio al que quedaría un artículo en 
--caso de aplicar un porcentaje de aumento pasado por parámetro.
create function f_porcentaje_aumento
(@porc decimal(4,2), @cod int)
returns @tabla table
(cod int, descr varchar(50), precio money) -- formato de la tabla
begin
	insert @tabla select cod_articulo, descripcion, pre_unitario*(@porc/100+1) from articulos
					where cod_articulo = @cod
	return
end
select * from dbo.f_porcentaje_aumento(10,2)

--4.4: Triggers
--1. Crear un desencadenador para las siguientes acciones:
--a. Restar stock DESPUES de INSERTAR una VENTA

alter trigger dis_venta_insert
on detalle_facturas
for insert
as
	declare @stock int
	select @stock = stock 
	from articulos join inserted on articulos.cod_articulo = inserted.cod_articulo
	if (select cantidad from inserted) <= @stock
		update articulos
		set stock = @stock-inserted.cantidad
		from articulos join inserted on articulos.cod_articulo=inserted.cantidad
	else
		begin
			raiserror ('El stock ingeresado es mayor al stock de articulos', 16,1)
			rollback transaction
		end
insert into facturas (fecha, cod_cliente, cod_vendedor) values (getdate(), 3, 2)
insert into detalle_facturas (nro_factura, cod_articulo, pre_unitario, cantidad) values (570, 1, 12, 10)

--b. Para no poder modificar el nombre de algún artículo
alter trigger dis_notupdate
on articulos
for update
as
	if update(descripcion)
	begin
		raiserror('No se puede modificar el nombre del Articulo',10,1)
		rollback transaction;
	end

update articulos
set descripcion = 'Goma'
where cod_articulo = 28

--c. Insertar en la tabla HistorialPrecio el precio anterior de un artículo si el 
--mismo ha cambiado

--d. Bloquear al vendedor con código 4 para que no pueda registrar ventas 
--en el sistema.
select * from vendedores
select * from detalle_facturas
select * from facturas

alter trigger dis_venta_vendedor_4
on facturas
for insert
as
	declare @codigo int
	select @codigo=inserted.cod_vendedor
	from vendedores join inserted on vendedores.cod_vendedor = inserted.cod_vendedor
	if (@codigo = 4)
	begin
		raiserror('El vendedor esta bloqueado temporalmente', 16,1)
		rollback transaction;
	end

insert into facturas (fecha,cod_cliente,cod_vendedor) values (getdate(), 2,3)
