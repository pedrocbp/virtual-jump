class_name EndlessLayoutValidator
extends RefCounted

# Limites calculados para plataformas de 100 px dentro de uma área de 360 px.
const MIN_PLATFORM_X := 60.0
const MAX_PLATFORM_X := 300.0
const MIN_CLEAR_CENTER_GAP := 80.0
const LANDING_TOLERANCE := 40.0

# Física padrão do Player. Estes valores ficam explícitos para o teste detectar
# qualquer mudança futura que torne o gerador incompatível com a movimentação.
const GRAVITY := 1200.0
const NORMAL_JUMP_FORCE := 500.0
const SPRING_JUMP_FORCE := 1080.0
const HORIZONTAL_ACCELERATION := 1800.0
const MAX_HORIZONTAL_SPEED := 190.0

static func is_platform_reachable(
		previous_x: float,
		candidate_x: float,
		vertical_gap: float,
		boosted_jump: bool,
		previous_motion_range: float = 0.0,
		candidate_motion_range: float = 0.0,
		adverse_wind_strength: float = 0.0
	) -> bool:
	if vertical_gap <= 0.0:
		return false
	if candidate_x - candidate_motion_range < MIN_PLATFORM_X:
		return false
	if candidate_x + candidate_motion_range > MAX_PLATFORM_X:
		return false

	var launch_force := SPRING_JUMP_FORCE if boosted_jump else NORMAL_JUMP_FORCE
	var discriminant := launch_force * launch_force - 2.0 * GRAVITY * vertical_gap
	if discriminant < 0.0:
		return false

	# Momento em que a bolinha volta descendo à altura da próxima plataforma.
	var flight_time := (launch_force + sqrt(discriminant)) / GRAVITY
	# O vento contrário é considerado durante todo o salto. A área real é
	# menor, portanto esta é uma margem conservadora.
	var horizontal_reach := maxf(0.0, _horizontal_distance(flight_time) - adverse_wind_strength * flight_time)
	var maximum_center_gap := horizontal_reach * 0.95 + LANDING_TOLERANCE
	var nominal_gap := absf(candidate_x - previous_x)
	var minimum_possible_gap := nominal_gap - previous_motion_range - candidate_motion_range
	var maximum_possible_gap := nominal_gap + previous_motion_range + candidate_motion_range

	# O mínimo evita bater na parte inferior da plataforma; o máximo reserva
	# margem para pousar sem exigir controle perfeito na borda.
	return minimum_possible_gap >= MIN_CLEAR_CENTER_GAP and maximum_possible_gap <= maximum_center_gap

static func choose_safe_x(
		preferred_x: float,
		previous_x: float,
		vertical_gap: float,
		boosted_jump: bool,
		previous_motion_range: float = 0.0,
		candidate_motion_range: float = 0.0,
		adverse_wind_strength: float = 0.0
	) -> float:
	var preferred_direction := 1.0 if preferred_x >= previous_x else -1.0
	var candidates: Array[float] = [preferred_x]
	for distance in [104.0, 112.0, 96.0, 120.0, 84.0]:
		candidates.append(previous_x + preferred_direction * distance)
		candidates.append(previous_x - preferred_direction * distance)
	for fixed_x in [72.0, 92.0, 112.0, 132.0, 152.0, 180.0, 208.0, 228.0, 248.0, 268.0, 288.0]:
		candidates.append(fixed_x)

	var best_x := NAN
	var best_score := INF
	for raw_x in candidates:
		var candidate_x := clampf(raw_x, MIN_PLATFORM_X + candidate_motion_range, MAX_PLATFORM_X - candidate_motion_range)
		if not is_platform_reachable(previous_x, candidate_x, vertical_gap, boosted_jump, previous_motion_range, candidate_motion_range, adverse_wind_strength):
			continue
		var direction_penalty := 0.0 if signf(candidate_x - previous_x) == preferred_direction else 18.0
		var score := absf(candidate_x - preferred_x) + direction_penalty
		if score < best_score:
			best_score = score
			best_x = candidate_x

	return best_x

static func is_spike_safe(platform_x: float, spike_x: float, arrival_direction: float) -> bool:
	if is_zero_approx(arrival_direction):
		return false
	var signed_offset := (spike_x - platform_x) * arrival_direction
	# O espinho fica no lado distante, preservando o lado de chegada.
	return signed_offset >= 26.0 and signed_offset <= 36.0

static func is_side_hazard_safe(
		platform_x: float,
		hazard_x: float,
		arrival_direction: float,
		movement_range: float = 0.0
	) -> bool:
	if is_zero_approx(arrival_direction):
		return false
	var nearest_signed_offset := (hazard_x - platform_x) * arrival_direction - movement_range
	return nearest_signed_offset >= 70.0

static func _horizontal_distance(duration: float) -> float:
	var acceleration_time := MAX_HORIZONTAL_SPEED / HORIZONTAL_ACCELERATION
	if duration <= acceleration_time:
		return 0.5 * HORIZONTAL_ACCELERATION * duration * duration
	var acceleration_distance := 0.5 * HORIZONTAL_ACCELERATION * acceleration_time * acceleration_time
	return acceleration_distance + MAX_HORIZONTAL_SPEED * (duration - acceleration_time)
