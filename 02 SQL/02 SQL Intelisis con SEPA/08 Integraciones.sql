

/*INICIO:INTEGRACION A STORED xpDespuesAfectar*/
/*Integrar AL FINAL*/


EXEC xpCA_DespuesAfectarAgendamientoCitasSeekop @Modulo,@ID,@Accion,@Base,@GenerarMov,@Usuario,@Ok OUTPUT,@OkRef OUTPUT

/*FIN:INTEGRACION A STORED xpDespuesAfectar*