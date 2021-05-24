

/*INICIO:INTEGRACION A STORED xpDespuesAfectar*/
/*Integrar en Modulo de VTAS*/

IF @Mov='Cita Servicio'
	BEGIN 
		EXEC xpCA_ConcluirCitaSePa @ID
		EXEC xpCA_ActualizacionEstatusMonitor @ID
	END
/*FIN:INTEGRACION A STORED xpDespuesAfectar*