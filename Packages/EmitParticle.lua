return function (particles: {ParticleEmitter})
	for _, particle in particles do
		if not particle:IsA("ParticleEmitter") then continue end
		local emitCount = particle:GetAttribute("EmitCount")
		local emitDelay = particle:GetAttribute("EmitDelay")
		if emitCount then
			if emitDelay and emitDelay > 0 then
				task.delay(emitDelay, particle.Emit, particle, emitCount)
			else
				particle:Emit(emitCount)
			end
		end
	end
end