

/*INICIO:INTEGRACION A STORED xpDespuesAfectar*/
/*Integrar en Modulo de VTAS*/

EXEC xpCA_DespuesAfectarAgendamientoCitasSeekop @Modulo,@ID,@Accion,@Base,@GenerarMov,@Usuario,@Ok OUTPUT,@OkRef OUTPUT

/*FIN:INTEGRACION A STORED xpDespuesAfectar*