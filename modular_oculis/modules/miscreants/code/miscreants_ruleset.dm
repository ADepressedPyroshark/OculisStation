/datum/dynamic_ruleset/roundstart/miscreants
	name = "Miscreants"
	config_tag = "Miscreants"
	pref_flag = ROLE_MISCREANT
	preview_antag_datum = /datum/antagonist/miscreant
	minimum_required_age = 0
	blacklisted_roles = list(
		JOB_AI,
		JOB_CAPTAIN,
		JOB_CYBORG,
		JOB_DETECTIVE,
		JOB_HEAD_OF_SECURITY,
		JOB_PRISONER,
		JOB_SECURITY_OFFICER,
		JOB_WARDEN,
		JOB_BLUESHIELD,
		JOB_NT_REP
	)
	min_pop = 10
	min_antag_cap = 1
	weight = 5 //needs to be adjusted for Oculis

/datum/dynamic_ruleset/roundstart/miscreant/assign_role(datum/mind/candidate)
	candidate.add_antag_datum(/datum/antagonist/miscreant)
