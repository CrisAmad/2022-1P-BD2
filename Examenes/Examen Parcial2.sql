
DROP procedure IF EXISTS SP_REGISTRO_PRODUCTO;
Delimiter //
CREATE PROCEDURE bd_factsv2.SP_REGISTRO_PRODUCTO(
    in p_idfactura int,
    in p_idproducto int,
    in p_cantidad int
 )
BEGIN 
    declare  v_idfactura int; 
    declare  v_idproducto int; 
    declare  v_cantidad int;
    declare  v_saldo_unidades int;
    declare  v_precio_venta decimal;
    declare  v_impuestosobre_venta decimal;

    set v_idfactura        = p_idfactura;
    set v_idproducto    = p_idproducto; 
    set v_cantidad        = p_cantidad;
    
    select saldoUnidades 
    into v_saldo_unidades 
    from tbl_productos 
    where idProducto=v_idproducto;
    
    select precioVenta 
    into v_precio_venta 
    from tbl_productos 
    where idProducto=v_idproducto;
    set v_impuestosobre_venta = v_precio_venta*0.15;

    if v_saldo_unidades >= v_cantidad then
        insert into tbl_productos_facturados
(idProducto,idFactura,cantidad,impuestosobreventa,precioVenta)
values 
(v_idproducto,v_idfactura,v_cantidad,v_impuestosobre_venta,v_precio_venta);

        update bd_factsv2.tbl_productos
        set saldounidades=saldounidades-v_cantidad 
        where idProducto=idProducto;

        update bd_factsv2.tbl_facturas set 
            cantidadProductos = cantidadProductos + v_cantidad,
            subTotalPagar = subTotalPagar + v_precio_venta,
            totalISV = totalISV + v_impuestosobre_venta,
            totalpagar = totalISV + subTotalPagar
        where idFactura=v_idfactura;
    end if;
    commit;
 END;
 
 CALL bd_factsv2.SP_REGISTRO_PRODUCTO(
207,              #v_idfactura
1026,            #v_producto
1                 #v_cantidad
);

 CALL bd_factsv2.SP_REGISTRO_PRODUCTO(
207,              #v_idfactura
1000,            #v_producto
3                 #v_cantidad
);
 
