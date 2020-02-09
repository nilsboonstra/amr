---------------
-- FUNCIONES --
---------------

--Devuelve un valor aleatorio de una distribucion normal de media
--med y desviacion desv con el metodo de Box-Muller
normrnd = function(med, desv)
    local U = math.random()
    local V = math.random()
    local X = math.sqrt(-2*math.log(U))*math.cos(2*math.pi*V)
    return (X*desv)+med
end

--FUNCIONES PARA ACTUADORES

--Proporciona velocidad al Motor 
On=function(inInts,inFloats,inStrings,inBuffer)
	if(finish ~= 1) then -- parámetro finish
		local speed
		if(inInts[2] > MAX_SPEED) then
			speed = MAX_SPEED
		elseif(inInts[2] < -MAX_SPEED) then
			speed = -MAX_SPEED
		else
			speed = inInts[2]
		end
		
		if(inInts[1] == 1) then -- Si es el valor de la constante del motor B
			--Activamos el motor B
			sim.setJointTargetVelocity(motorB, speed)
			sim.setJointForce(motorB, MOTION_TORQUE)
		elseif(inInts[1] == 2) then -- Si es el valor de la constante del motor C
			--Activamos el motor C
			sim.setJointTargetVelocity(motorC, speed)
			sim.setJointForce(motorC, MOTION_TORQUE)
		elseif(inInts[1] == 3) then -- Si es el valor de la constante de ambos motores
			--Activamos ambos motores
			sim.setJointTargetVelocity(motorB, speed)
			sim.setJointTargetVelocity(motorC, speed)
			sim.setJointForce(motorB, MOTION_TORQUE)
			sim.setJointForce(motorC, MOTION_TORQUE)
		end
	end
	return {},{},{},''
end

--Detiene los motores
Off=function(inInts,inFloats,inStrings,inBuffer)
	if(finish ~= 1) then -- parámetro finish
		if(inInts[1] == 1) then -- Si es el valor de la constante del motor B
			--Paramos el motor A
			sim.setJointTargetVelocity(motorB, 0)
			sim.setJointForce(motorB, REST_TORQUE)
		elseif(inInts[1] == 2) then -- Si es el valor de la constante del motor C
			--Paramos el motor C
			sim.setJointTargetVelocity(motorC, 0)
			sim.setJointForce(motorC, REST_TORQUE)
		elseif(inInts[1] == 3) then -- Si es el valor de la constante de ambos motores
			--Paramos ambos motores
			sim.setJointTargetVelocity(motorB, 0)
			sim.setJointTargetVelocity(motorC, 0)
			sim.setJointForce(motorB, REST_TORQUE)
			sim.setJointForce(motorC, REST_TORQUE)
		end
	end
	return {},{},{},''
end

-- FUNCIONES PARA SENSORES

--Devuelve la rotacion del Motor B
MotorRotationCountB=function(inInts,inFloats,inStrings,inBuffer)
    if(finish ~= 1) then -- Parámetro finish
        local rotation = sim.getJointPosition(motorB) -- recogemos el angulo de rotacion
        if(rotation < 0) then -- y agustamos según el origen mediante la variable reset
            rotation = math.ceil(math.deg(rotation-resetB))
        else
            rotation = math.floor(math.deg(rotation-resetB))
        end
        return {rotation},{},{},'' -- devolvemos el resultado.
    else
        return{},{},{},''
    end
end

--Devuelve la rotacion del Motor C
MotorRotationCountC=function(inInts,inFloats,inStrings,inBuffer)
    if(finish ~= 1) then -- Parámetro finish
        local rotation = sim.getJointPosition(motorC) -- recogemos el angulo de rotacion
        if(rotation < 0) then -- y agustamos según el origen mediante la variable reset
            rotation = math.ceil(math.deg(rotation-resetC))
        else
            rotation = math.floor(math.deg(rotation-resetC))
        end
        return {rotation},{},{},'' -- devolvemos el resultado.
    else
        return{},{},{},''
    end
end

--Reinicializa los encoders desde la posicion actual
ResetRotationCount=function(inInts,inFloats,inStrings,inBuffer)
    if(finish ~= 1) then -- Parámetro finish
        local motor = inInts[1] -- se recoje el tipo de motor
        if(motor == 1)then -- si es B establece el origen de B
            resetB = sim.getJointPosition(motorB)
        elseif(motor == 2)then -- si no, establece el origen de C
            resetC = sim.getJointPosition(motorC)
        end
    end
    return {},{},{},''
end

--Devuelve la informacion del sensor tactil
SensorTouch=function(inInts,inFloats,inStrings,inBuffer)
    if(finish ~= 1) then -- parámetro finish
		local res -- variable de resultado
        local state, forceVector = sim.readForceSensor(bumper) -- se leen los datos del sensor
		                                                      -- y se obtienen el estado y el
															  -- vector de fuerza
		if (state > 0) then -- si ha detectado pulsación
            if ((forceVector[3]>1))then -- comprobamos si se ha ejercido una fuerza de mas de
			                            -- 1N y devoleremos como resultado 1
                res = 1;
            else -- en otro caso devolveremos 0
                res = 0;
            end
        else -- en otro caso devolveremos 0
            res = 0;
        end
		return {res},{},{},'' -- se devuelve el resultado
    else
        return {},{},{},''
    end
end

--Devuelve la informacion del sonar
SensorSonar=function(inInts,inFloats,inStrings,inBuffer)
    if(finish ~= 1) then -- parámetro finish
        local detect, dist = sim.readProximitySensor(sonar) -- se leen los parámetros
														   -- del sensor de proximidad
		local aux = 255 -- se asigna el valor de "no detectado" por defecto
		if(dist ~= nil and detect > 0) then -- si ha ha detectado correctamente
			aux = math.floor(dist*1000+normrnd(0,0.5))/10 -- se realizan los ajustes
		end
        return {},{aux},{},'' -- se devuelven los datos
    else
        return {},{},{},''
    end
end

-- Devuelve el valor medio de intensidad de luz
SensorLight=function(inInts,inFloats,inStrings,inBuffer)
    if(finish ~= 1) then -- parámetro finish
        local auxData = select(2,sim.readVisionSensor(sensorColorLR))
		local desv = 0.2905 + 0.3197*auxData[11];
		local aux = 7+64*auxData[11]+normrnd(0,desv) -- Se escala el valor y se le aplica el error
        return {math.floor(aux)},{},{},''
    else
        return {},{},{},''
    end
end

-- Devuelve los valores rgb medios y la profundidad) del sensor de color
SensorColor=function(inInts,inFloats,inStrings,inBuffer)
    if(finish ~= 1) then -- parámetro finish
        local auxData = select(2,sim.readVisionSensor(sensorColorLR))
        return {},{auxData[12], auxData[13], auxData[14], auxData[15]},{},''
    else
        return {},{},{},''
    end
end

-- devuelve la velocidad angular
SensorGyroVA=function(inInts,inFloats,inStrings,inBuffer)
    if(finish ~= 1) then -- parámetro finish
        local gyroZ = sim.getIntegerSignal('gyroZ_velocity')
		-- se recoge la velocidad angular del giroscopio y la devolvemos
        return {gyroZ},{},{},''
    else
        return {},{},{},''
    end
end

-- devuelve el angulo girado
SensorGyroA=function(inInts,inFloats,inStrings,inBuffer)
    if(finish ~= 1) then -- parámetro finish
        local gyroZ = sim.getIntegerSignal('gyroZ_angle')
		-- se recoge el angulo girado del giroscopio y lo devolvemos
        return {gyroZ},{},{},''
    else
        return {},{},{},''
    end
end

-- resetea el angulo girado
ResetGyroA=function(inInts,inFloats,inStrings,inBuffer)
    if(finish ~= 1) then -- parámetro finish
        sim.setIntegerSignal('gyroZ_angle_reset', 1)
		-- se resetea el conteo de ángulos
    end
        return {},{},{},''
end

-- FUNCIONES DE LA INTERFAZ

--Añade un texto en pantalla dependiendo de la linea indicada
TextOut=function(inInts,inFloats,inStrings,inBuffer)
    if(finish ~= 1) then -- Parámetro finish
		if(inInts[1] >= 1 and inInts[1] <= 8) then
			simSetUIButtonLabel(UI, inInts[1], inStrings[1])
		end
    end
    return {},{},{},''
end

--limpia la pantalla (consola auxiliar)
ClearScreen=function(inInts,inFloats,inStrings,inBuffer)
    if(finish ~= 1) then -- Parámetro finish
        for i=1,8 do
            simSetUIButtonLabel(UI, i, '')
        end
    end
    return {},{},{},''
end

StatusLight=function(inInts,inFloats,inStrings,inBuffer)
	if(finish ~= 1) then -- Parámetro finish
		stroke = inInts[2]
		if (inInts[1] >= 1 and inInts[1] <= 4) then
			color = LIGHTS[inInts[1]]
		else
			color = LIGHTS[4]
		end
		simSetUIButtonColor(UI, 17, color, nil)
		simSetUIButtonColor(UI, 18, color, nil)
	end
	return {},{},{},''
end

ButtonPressed=function(inInts,inFloats,inStrings,inBuffer)
    if(finish ~= 1) then -- parámetro finish
		return {button},{},{},''
	else
		return {},{},{},''
	end
end

-- OTRAS FUNCIONES

--Devuelve el valor del paso de simulación en segundos
SimulationTimeStep=function(inInts,inFloats,inStrings,inBuffer)
	return {},{sim.getSimulationTimeStep()},{},''
end

--Función vacia que nos servirá para realizar esperas
EmptyFunction=function(inInts,inFloats,inStrings,inBuffer)
	return {},{},{},''
end

--Devuelve el tiempo actual de ejecucion (tiempo de simulación en ms)
CurrentTick=function(inInts,inFloats,inStrings,inBuffer)
    if(finish ~= 1) then -- Parámetro finish
        return {},{sim.getSimulationTime()},{},''
    else
        return {},{},{},''
    end
end

--Finaliza el programa
Stop = function(inInts,inFloats,inStrings,inBuffer)
	-- volvemos a cero el resto de variables
    waitTimeTotal = 0
    resetB = 0
    resetC = 0
    lastTime = 0
	button = 0
	-- limpiamos la consola auxiliar y las luces de estado
	ClearScreen({},{},{},'')
	StatusLight({4, 0},{},{},'')
	-- paramos los motores
    sim.setJointTargetVelocity(motorB, 0)
    sim.setJointTargetVelocity(motorC, 0)
	-- limpiamos todas las señales
    sim.clearFloatSignal(nil)
    sim.clearIntegerSignal(nil)
    sim.clearStringSignal(nil)
	-- si obtenemos un valor negativo en el argumento,
	-- quiere decir que el programa de matlab no se ha finalizado correctamente
	if(inInts[1] < 0) then
		sim.addStatusbarMessage('HA OCURRIDO UN ERROR EN EL CLIENTE A LA HORA DE FINALIZAR EL PROGRAMA')
	end
	finish = 1 -- variable global finish para impedir ejecuciones de funciones y fases del robot
    return {},{},{},''
end

----------------------------
-- FASES DE LA SIMULACIÓN --
----------------------------

-- PARTE DE INICIALIZACIÓN
if (sim_call_type==sim.syscb_init) then
	-- Constantes
	MOTION_TORQUE = 0.2 -- Torque en movimiento de los motores
	REST_TORQUE = 0.4  --Torque en parada de los motores
	MAX_SPEED = 18.326 -- Máxima velocidad para los motores
	LIGHTS = {{0, 1, 0}, {0.89, 0.54, 0.23}, {1, 0, 0}, {0.85, 0.85, 0.85}} -- Array de colores para la luz de estado
	PUERTO_API_REMOTA = sim.getScriptSimulationParameter(sim.handle_self, 'PUERTO_API_REMOTA', false) -- Puerto de api remota
	
	-- Variables globales
    lastTime = 0 -- Tiempo de simulación anterior
	currentTime = 0 -- Tiempo de simulación actual
    finish = 0 -- variable que acaba con la ejecución de las fases y no permite el uso de funciones; usado en la función close.
    resetB = 0 -- variable que guarda el último valor del encoder A llamado por la funcion ResetRotationCount
    resetC = 0 -- variable que guarda el último valor del encoder C llamado por la funcion ResetRotationCount
	button = 0 -- variable que guarda el último ID del boton pulsado
	stroke = 0 -- variable que indica si la luz de estado debe parpadear (0 no, 1 sí)
	turn = 0 -- variable que indica que la luz de estado debe apagarse o encenderse si esta parpadea
	timestroke = 0 -- tiempo en un estado de parpadeo para la luz de estado
	color = LIGHTS[4] -- color actual de la luz de estado (apagado)
    
	-- Inicio de señales
    sim.setIntegerSignal('SendStop',0) -- esta señal se encarga de indicarle a Matlab que el wait ha finalizado
    
	-- Referencias de objetos
    motorB = sim.getObjectHandle('Motor_B') -- Referencia del motor_B para EV3
    motorC = sim.getObjectHandle('Motor_C') -- Referencia para el motor
    bumper = sim.getObjectHandle('Bumper') -- Referencia del sensor táctil
    sonar = sim.getObjectHandle('Sonar') -- Referencia del sensor ultrasónico
    sensorColorLR = sim.getObjectHandle('Sensor_Color_LR') -- Referencia para el modo luz reflejada del sensor de color
    sensorColorRC = sim.getObjectHandle('Sensor_Color_RC') -- Referencia para el modo color del sensor de color
	
	-- Referencia de interfaz
	UI = simGetUIHandle('Interfaz_EV3')
	
	-- Inicio del servidor de API remota para el robot
	simRemoteApi.start(PUERTO_API_REMOTA, 1300, false, false)
    simRemoteApi.start(19999)
end

-- PARTE DE ACTUACIÓN
if (sim_call_type==sim.syscb_actuation and finish ~= 1) then

end


-- PARTE DE SONDEO
if (sim_call_type==sim.syscb_sensing and finish ~= 1) then
    currentTime = sim.getSimulationTime()
	
    -- Listener de los botones del ladrillo  (escribe en la variable el ultimo boton pulsado)
	local event, state = simGetUIEventButton(UI)
	if(event ~= -1) then -- si se ha producido un evento de pulsación o de soltar un botón de la interfaz
		if(state[2] == 1) then -- si se ha pulsado, escribimos el id del boton pulsado
			button = event - 10
		else -- si se ha dejado de pulsar, escribimos 0 que indica que ningún botón se esta pulsando
			button = 0
		end
	end
	
	-- Controlador del parpadeo del led de estado
	if(stroke == 1) then --si se ha indicado parpadeo
		timestroke = timestroke + (currentTime-lastTime) -- calculamos el tiempo que el led lleva en un estado
		if(timestroke >= 0.5) then -- si se ha superado el tiempo establecido para el estado
			if(turn == 0) then -- si están apagadas, las encendemos con el color indicado
				simSetUIButtonColor(UI, 17, color, nil)
				simSetUIButtonColor(UI, 18, color, nil)
				turn = 1 -- cambiamos de estado
			else -- en otro caso, las apagamos
				simSetUIButtonColor(UI, 17, LIGHTS[4], nil)
				simSetUIButtonColor(UI, 18, LIGHTS[4], nil)
				turn = 0 --  cambiamos de estado
			end
			timestroke = 0
		end
	end
	
	lastTime=currentTime -- almacenamos el tiempo actual para utilizarlo en el siguiente paso de simulación
end

-- PARTE DE RESTAURACIÓN
if (sim_call_type==sim.syscb_cleanup) then 
	-- se apagan las luces de estado
	simSetUIButtonColor(UI, 17, LIGHTS[4], nil)
	simSetUIButtonColor(UI, 18, LIGHTS[4], nil)
	-- se detiene el servidor de API remota de este robot
	simRemoteApi.stop(PUERTO_API_REMOTA)
end 
