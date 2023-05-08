--Tema 1
--1. Crear una funci�n que devuelva el nombre completo del due�o con el apellido todo en
--may�sculas, coma, espacio y el nombre con la 1er. letra en may�sculas y el resto en
--min�sculas
create function F_Due�o
(@cod_Due�o int)
returns varchar(100)
begin  
declare @cadena varchar(100)
set @cadena=(select upper(apellido)+', '+upper(left(nombre,1))+lower(substring(nombre,2,len(nombre)))Due�o
             from due�os )
return @cadena
end
--2. Crear una vista que muestre el listado de mascotas (nombre, tipo, raza, edad) con sus due�os
--(nombre completo utilizando la funci�n del punto 1, direcci�n completa, tel�fono)
create view Vis_Mascotas
as
select m.id_mascota Codigo,nombre Mascota,tipo,raza,fec_nac'Fecha Nacimiento',year(getdate())-year(fec_nac)'Edad',
dbo.f_Due�o(d.id_due�o),telefono,calle+'N� '+trim(str(altura))'Direccion',barrio
from due�os d join mascotas m on d.id_due�o=m.id_due�o
join razas r on r.id_raza=m.id_raza
join tipos t on t.id_tipo=m.id_tipo
join barrios b on b.id_barrio=d.id_barrio
--3. Consultar la vista anterior mostrando nombre y raza de perros con m�s de 5 a�os, de due�os
--con tel�fono conocido (mostrar nombre de due�o y tel�fono), que vinieron a consulta este a�o
select Codigo,Mascota,raza,Edad
from Vis_Mascotas
where Edad>5 and 
      telefono is not null
	  and Codigo in (select Codigo
	                 from consultas 
					 where year(fecha)=year(getdate())
					 )
--Otra Forma
select Codigo,Mascota,raza,Edad
from Vis_Mascotas v join consultas c on v.Codigo=c.id_mascota
where Edad>5 and 
      telefono is not null and 
	  year(fecha)=year(getdate())
--4. Mostrar los importes totales cobrados mensualmente por cada m�dico entre los a�os que se
--ingresar�n por par�metro
create procedure SP_Totales_Mensuales
@A�o1 datetime,
@A�o2 datetime
as
select year(fecha)'A�o',month(fecha)'Mes',m.id_medico'Codigo Medico',apellido+space(3)+nombre Medico,
sum(importe)'Importe Total'
from consultas c join medicos m on c.id_medico=m.id_medico
where year(fecha) between @A�o1 and @A�o2
group by  year(fecha),month(fecha),m.id_medico,apellido+space(3)+nombre
--5. Crear un trigger que impida que se modifique el importe de las consultas.create trigger No_Upd_Importeson consultasfor updateasif(update(importe))beginraiserror('No se puede modificar el importe de la consulta',10,1)rollback transactionend--Tema 2--1. Crear un procedimiento almacenado para insertar un nuevo m�dico. 
create procedure Ins_Medico
@nombre varchar(50),
@apellido varchar(50),
@fec_ingreso datetime,
@calle varchar(100),
@altura char(4),
@telefono int,
@matricula int,
@id_barrio int
as
begin
insert into medicos(nombre,apellido,fec_ingreso,calle,altura,telefono,matricula,id_barrio)
values(@nombre,@apellido,@fec_ingreso,@calle,@altura,@telefono,@matricula,@id_barrio)
end
--2. Modificar el procedimiento anterior para que en caso de que la matricula o el apellido sean
--nulos no permita hacer el insert y de un error por excepci�n
alter procedure Ins_Medico
@nombre varchar(50),
@apellido varchar(50),
@fec_ingreso datetime,
@calle varchar(100),
@altura char(4),
@telefono int,
@matricula int,
@id_barrio int
as
if(@matricula is null or @apellido is null)
begin 
raiserror('Ingrese valores validos no nulos',10,1)
insert into #Errores (nro_error,mensaje) values(ERROR_NUMBER(),ERROR_MESSAGE())
rollback transaction
end
else
begin
insert into medicos(nombre,apellido,fec_ingreso,calle,altura,telefono,matricula,id_barrio)
values(@nombre,@apellido,@fec_ingreso,@calle,@altura,@telefono,@matricula,@id_barrio)
end
--3. Cree una tabla temporal para guardar los errores del punto 2
create table #Errores
(id int identity(1,1),
nro_error int,
mensaje varchar(500)
constraint pk_error primary key(id)
)
--4. Crear una vista que liste la cantidad de consultas, importe total y promedio de importe, mayor
--y menor importe por due�o por a�o
create view Vis_Consultas
as
select year(fecha)'A�o',d.id_due�o'codigo due�o',apellido+space(3)+nombre Due�o,
count(c.id_consulta)'Cantidad Consultas',sum(importe)'importe total',
avg(importe)'promedio importe',min(importe)'menor importe',max(importe)'mayor importe'
from consultas c join mascotas m on c.id_mascota=m.id_mascota
join due�os d on d.id_due�o=m.id_due�o
group by year(fecha),d.id_due�o,apellido+space(3)+nombre
--5. Consultar la vista anterior mostrando el due�o, importe total y cantidad de consultas
--realizadas el a�o pasado cuyo importe promedio sea mayor al importe promedio de todas las
--consultas de este a�o
select [codigo due�o],Due�o,[Cantidad Consultas],[importe total]
from Vis_Consultas
where A�o=year(getdate())-1 and 
      [promedio importe]>(select avg(importe)
	                      from consultas 
						  where year(fecha)=year(getdate())
						  )