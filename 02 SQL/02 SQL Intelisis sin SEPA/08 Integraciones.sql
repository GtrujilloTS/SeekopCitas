

/*INICIO:INTEGRACION A STORED xpCA_DespuesAfectarMarca*/
/*Integrar en Modulo de VTAS*/

EXEC xpCA_DespuesAfectarAgendamientoCitasSeekop @Modulo,@ID,@Accion,@Base,@GenerarMov,@Usuario,@Ok OUTPUT,@OkRef OUTPUT

/*FIN:INTEGRACION A STORED xpCA_DespuesAfectarMarca*