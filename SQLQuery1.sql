Create DataBase automotriz
go
use automotriz 
go


create table Barrios
(idBarrio int identity (1,1),
barrio varchar(50),
constraint pk_barrio primary key (idBarrio))

create table Formas_Pago
(idFormaPago int identity (1,1),
formaPago varchar(50), 
constraint pk_forma_pago primary key (idFormaPago))

create table Tipos_Clientes
(idTipoCliente int identity (1,1),
descripcion varchar(50),
constraint pk_tipo_cliente primary key (idTipoCliente))

create table Auto_Planes
(idAutoPlan int identity (1,1),
cuotas int,
interes int
constraint pk_auto_plan primary key(idAutoPlan))


create table Clientes
(idCliente int identity (1,1),
nomCliente varchar(50),
apeCliente varchar(50),
calle varchar(50),
altura int,
idBarrio int,
idTipoCliente int,
constraint pk_cliente primary key (idCliente),
constraint fk_barrio_cliente foreign key (idBarrio) references Barrios (idBarrio),
constraint fk_tipo_cliente foreign key (idTipoCliente) references Tipos_Clientes (idTipoCliente))

create table Facturas
(nroFactura int identity (1,1),
idCliente int,
fecha datetime,
descuento int,
idAutoPlan int,
idFormaPago int,
 constraint pk_facturas primary key (nroFactura),
 constraint fk_cliente_factura foreign key (idCliente) references Clientes(idCliente),
 constraint fk_forma_pago_Factura foreign key (idFormaPago) references Formas_Pago (idFormaPago),
 constraint fk_auto_plan_factura foreign key (idAutoPlan) references Auto_Planes (idAutoPlan))

 create table Pedidos
 (nroPedido int identity (1,1),
 fechaOrden datetime,
 fechaPedido datetime,
 idCliente int,
 constraint pk_pedidos primary key(nroPedido),
 constraint fk_cliente_pedido foreign key (idCliente) references Clientes(idCliente))

 create table Tipos_Productos
 (idTipoProducto int identity (1,1),
 descripcion varchar(50),
 constraint pk_tipo_producto primary key (idTipoProducto))

 create table Productos 
 (idProducto int identity (1,1),
 descripcion varchar(50),
 stock_min int,
 stock_actual int,
 precio money, 
 idTipoProducto int,
 constraint pk_productos primary key (idProducto),
 constraint fk_tipo_prod foreign key (idTipoProducto) references Tipos_Productos (idTipoProducto))

 create table Historial
 (idHistorial int identity (1,1),
 idProducto int,
 precio money,
 fecha datetime,
 constraint pk_historial primary key (idHistorial, idProducto),
 constraint fk_producto_hist foreign key (idProducto) references Productos(idProducto))

 create table Detalles_Factura
 (idDetalleFactura int,
 nroFactura int,
 idProducto int,
 cantidad int,
 pre_unitario money,
 constraint pk_detalleFactura primary key (idDetalleFactura,nroFactura),
 constraint fk_factura_detalle foreign key(nroFactura) references Facturas(nroFactura),
 constraint fk_producto_detalle foreign key(idProducto) references Productos(idProducto))

 create table Detalles_Pedidos
 (idDetallePedido int,
 nroPedido int,
 idProducto int,
 cantidad int,
constraint pk_detalle_pedidos primary key (idDetallePedido, nroPedido),
constraint fk_pedido_detalle foreign key (nroPedido) references Pedidos(nroPedido),
constraint fk_detalle_producto foreign key(idProducto) references Productos(idProducto))

insert into Tipos_Productos values ('Automóvil')
insert into Tipos_Productos values ('Autoparte')

insert into Barrios values ('Nueva Córdoba')
insert into Barrios values ('Alta Córdoba')
insert into Barrios values ('Poeta Lugones')
insert into Barrios values ('Micro Centro')
insert into Barrios values ('Argüello')
insert into Barrios values ('Zona Norte')
insert into Barrios values ('Chateau')
insert into Barrios values ('Hernando')
insert into Barrios values ('Alberdi')

insert into Formas_Pago values ('Crédito')
insert into Formas_Pago values ('Débito')
insert into Formas_Pago values ('Efectivo')
insert into Formas_Pago values ('Cheque')
insert into Formas_Pago values ('Transferencia')

insert into Tipos_Clientes values ('Consumidor Final')
insert into Tipos_Clientes values ('Empresa')
insert into Tipos_Clientes values ('Concesionario')
insert into Tipos_Clientes values ('Casa de Repuestos')

alter procedure spInsertarFacturaMaestro
@idCliente int,
@fecha datetime,
@descuento int,
@idFormaPago int,
@idAutoPlan int,
@id int output
as
insert into Facturas values (@idCliente, @fecha, @descuento, @idAutoPlan, @idFormaPago, 1)
set @id = SCOPE_IDENTITY();

select * from Facturas

create procedure spInsertarFacturaDetalle
@nroFactura int,
@idDetalleFactura int,
@idProducto int,
@cantidad int,
@pre_unitario money
as
insert into Detalles_Factura values (@idDetalleFactura, @nroFactura, @idProducto, @cantidad, @pre_unitario)

create procedure SpInsertarPedidoMaestro
@id int output,
@fechaOrden datetime,
@fechaPedido datetime,
@idCliente int
as 
insert into Pedidos values (@fechaOrden, @fechaPedido, @idCliente)
set @id = SCOPE_IDENTITY();

create procedure SpInsertarPedidoDetalle
@nroPedido int,
@idDetallePedido int,
@idProducto int,
@cantidad int
as
insert into Detalles_Pedidos values (@idDetallePedido, @nroPedido, @idProducto, @cantidad)

create procedure SpInsertarCliente
@nomCliente varchar (50),
@apeCliente varchar (50),
@calle varchar(50),
@altura int,
@idBarrio int,
@idTipoCliente int
as
insert into Clientes values (@nomCliente,@apeCliente,@calle,@altura,@idBarrio,@idTipoCliente)

create procedure spInsertarProducto
@descripcion varchar (50),
@stock_min int,
@stock_actual int,
@precio money,
@idTipoProducto int
as
insert into Productos values (@descripcion,@stock_min,@stock_actual,@precio,@idTipoProducto)

create procedure spConsultarTipoProducto
as
select * from Tipos_Productos

create procedure spConsultarTipoCliente
as
select * from Tipos_Clientes

create procedure spConsultarDetalle
@idFactura int
as
select * from Detalles_Factura
where nroFactura = @idFactura

alter procedure spConsultarFacturas
@idCliente int
as
select * from Facturas
where idCliente = @idCliente and activo = 1

create procedure spConsultarConIndice
@idProducto int
as
select * from Productos where idProducto = @idProducto

alter table Facturas
add activo bit

create procedure spReadAutoPlanConId
@id int
as
select * from Auto_Planes where idAutoPlan = @id

create procedure spReadFormasPagoConId
@id int
as
select * from Formas_Pago where idFormaPago = @id

select * from Facturas

update Facturas
set activo = 1

create procedure spBorrarFactura
@id int
as
update Facturas
set activo = 0
where nroFactura = @id

insert into Productos values ('Bujía', 50, 75, 5000, 2)
insert into Productos values ('Kit de distrubición', 43, 58, 10000, 2)
insert into Productos values ('Motor', 15,20 , 50000, 2)
insert into Productos values ('Paragolpe delantero', 50, 80, 100000, 2)
insert into Productos values ('Capot', 50, 75, 11000, 2)
insert into Productos values ('Paragolpe trasero', 50, 75, 120000, 2)
insert into Productos values ('Filtro de aceite', 75, 92, 40000, 2)
insert into Productos values ('Filtro de aire', 75, 102, 45000, 2)
insert into Productos values ('Chery QQ', 2, 2, 234743, 1)
insert into Productos values ('VW Gol', 2, 3, 286039, 1)
insert into Productos values ('Ford Ka', 2, 4,286300, 1)
insert into Productos values ('Nissan March', 1, 2, 266000, 1)
insert into Productos values ('Hilux', 2, 3, 5000000, 1)
insert into Productos values ('Renault Sandero', 1, 2, 287500, 1)
insert into Productos values ('Amarok', 1, 2, 20000000, 1)