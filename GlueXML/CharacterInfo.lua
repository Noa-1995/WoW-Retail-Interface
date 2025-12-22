-- Autora: Noa

-- Contiene las estructuras de datos para las razas y clases del juego

--ES
local Races_Informations = {
[1] = {
      Name = "Humano",
	  Description = "Los humanos son una raza joven y, por lo tanto, muy versátil. Dominan las artes del combate, la artesanía y la magia con una eficacia sorprendente. Su valor y optimismo los han llevado a levantar algunos de los reinos más espléndidos del mundo. En esta turbulenta era, tras generaciones de conflictos, los humanos quieren recuperar la gloria que los distinguió otrora y forjarse un nuevo y brillante futuro.",
	  Spell_1 = {name = "Cada Hombre por Sí Mismo", icon = "spell_shadow_charm", description = "Elimina todos los efectos que impiden el movimiento y todos los efectos que provocan pérdida de control de tu personaje."},
	  Spell_2 = {name = "Especialización con Espadas", icon = "ability_meleedamage", description = "La pericia con Espadas y Espadas de Dos Manos aumenta en 3."},
	  Spell_3 = {name = "Especialización con Mazas", icon = "inv_hammer_05", description = "La pericia con Mazas y Mazas de Dos Manos aumenta en 3."},
	  Spell_4 = {name = "El Espíritu Humano", icon = "inv_enchant_shardbrilliantsmall", description = "Espíritu aumentado en un 3%."},
	  Spell_5 = {name = "Percepción", icon = "spell_nature_sleep", description = "Aumenta tu detección de Sigilo."},
	  Spell_6 = {name = "Diplomacia", icon = "inv_misc_note_02", description = "La ganancia de reputación aumenta en un 10%."},
	 },	 
[2] = {
      Name = "Enano",
	  Description = "En el pasado, los enanos solo se preocupaban por las riquezas extraídas de las entrañas de la tierra. Fue así como hallaron vestigios de una raza divina que, según parece, les dio vida... y derecho de nacimiento encantado. Impulsados a aprender más por este descubrimiento, los enanos se consagraron a la búsqueda de artefactos perdidos y el conocimiento arcano. Hoy en día, hay arqueólogos enanos repartidos por todo el mundo.",
	  Spell_1 = {name = "Especialización con Mazas", icon = "inv_hammer_05", description = "La pericia con Mazas y Mazas de Dos Manos aumenta en 5."},
	  Spell_2 = {name = "Forma de Piedra", icon = "spell_shadow_unholystrength", description = "Elimina todos los efectos de veneno, enfermedad y sangrado, además aumenta tu armadura en un 10% durante 0.1 segundos."},
	  Spell_3 = {name = "Especialización con Armas de Fuego", icon = "inv_musket_03", description = "Tu probabilidad de golpe crítico con Armas de Fuego aumenta en un 1%."},
	  Spell_4 = {name = "Resistencia a la Escarcha", icon = "spell_frost_wizardmark", description = "Reduce la probabilidad de ser alcanzado por hechizos de Escarcha en un 2%."},
	  Spell_5 = {name = "Detectar Tesoro", icon = "racial_dwarf_findtreasure", description = "Permite al enano percibir tesoros cercanos, mostrándolos en el minimapa. Dura hasta cancelación."},
	 },	 
[3] = {
      Name = "Elfo de la Noche",
	  Description = "Hace diez mil años, los elfos de la noche fundaron un vasto imperio, pero el uso imprudente de la magia primaria los llevó a la ruina. Consternados, se retiraron a los bosques donde se aislaron hasta el regreso de su antiguo enemigo: la Legión Ardiente. Entonces no tuvieron más opción que abandonar su reclusión y luchar por su lugar en el nuevo mundo.",
	  Spell_1 = {name = "Fusión en las Sombras", icon = "ability_ambush", description = "Actívalo para deslizarte en las sombras, reduciendo la probabilidad de ser detectado por los enemigos. Dura hasta ser cancelado o al moverte. Al cancelarse, toda la amenaza se restaura contra enemigos aún en combate."},
	  Spell_2 = {name = "Elusividad", icon = "ability_racial_ultravision", description = "Reduce la probabilidad de ser detectado mientras estás en Sigilo o en Fusión en las Sombras."},
	  Spell_3 = {name = "Resistencia a la Naturaleza", icon = "spell_nature_spiritarmor", description = "Reduce la probabilidad de ser alcanzado por hechizos de Naturaleza en un 2%."},
	  Spell_4 = {name = "Presteza", icon = "ability_racial_shadowmeld", description = "Reduce en un 2% la probabilidad de ser alcanzado por ataques cuerpo a cuerpo y a distancia."},
	  Spell_5 = {name = "Espíritu de Fuego Fatuo", icon = "spell_nature_wispsplode", description = "Te transformas en un fuego fatuo al morir, aumentando tu velocidad en un 75%."},  
	 },
[4] = {
      Name = "Gnomo",
	  Description = "A pesar de su baja estatura, los gnomos de Khaz Modan usaron su prodigioso intelecto para asegurarse un lugar en la Historia. Sin ninguna duda, su reino subterráneo, Gnomeregan, era una maravilla de la tecnología a vapor. Pero así y todo, perdieron la ciudad durante una invasión masiva de troggs. Ahora, los creadores de esta maravilla vagan por las tierras de los enanos, ayudándoles lo mejor que pueden.",
	  Spell_1 = {name = "Artista del Escape", icon = "ability_rogue_trip", description = "Escapas de cualquier efecto que te inmovilice o reduzca tu velocidad de movimiento."},
	  Spell_2 = {name = "Resistencia Arcana", icon = "spell_nature_wispsplode", description = "Reduce la probabilidad de ser alcanzado por hechizos Arcanos en un 2%."},
	  Spell_3 = {name = "Mente Expansiva", icon = "inv_enchant_essenceeternallarge", description = "Intelecto aumentado en un 5%."},
	  Spell_4 = {name = "Especialización en Ingeniería", icon = "inv_misc_gear_01", description = "Habilidad en Ingeniería aumentada en 15."},  
	 },
[5] = {
      Name = "Draenei",
	  Description = "Lejos de su hogar, Argus, los honorables draenei huyeron de la Legión Ardiente durante eones antes de encontrar un planeta remoto donde asentarse. Compartieron ese mundo con los chamanísticos orcos y lo llamaron Draenor. Con el tiempo, la Legión corrompió a los orcos, quienes hicieron la guerra y casi exterminaron a los pacíficos draenei. Unos pocos afortunados escaparon y llegaron a Azeroth donde ahora buscan aliados en su batalla contra la Legión Ardiente.",
	  Spell_1 = {name = "Don de los Naaru", icon = "spell_holy_holyprotection", description = "Sana al objetivo durante 15 seg. La cantidad de sanación aumenta con tu poder de ataque."},
	  Spell_2 = {name = "Tallado de Gemas", icon = "spell_misc_conjuremanajewel", description = "Habilidad en Joyería aumentada en 5."},
	  Spell_3 = {name = "Presencia Heroica", icon = "inv_helmet_21", description = "Aumenta la probabilidad de acierto con todos los ataques y hechizos en un 1% para ti y todos los miembros de tu grupo en un radio de 30 m."},
	  Spell_4 = {name = "Resistencia a las Sombras", icon = "spell_shadow_detectinvisibility", description = "Reduce la probabilidad de ser alcanzado por hechizos de Sombras en un 2%."},
	 },
[6] = {
      Name = "Orco",
	  Description = "La raza de los orcos es originaria del planeta Draenor. Este pueblo pacífico, de creencias chamánicas, fue esclavizado por la Legión Ardiente y forzado a participar en la guerra contra los humanos de Azeroth. Aunque tuvieron que pasar muchos años, al final escaparon de la corrupción de los demonios y recuperaron su libertad. A día de hoy, luchan por su honor en un mundo que los odia y desprecia.",
	  Spell_1 = {name = "Furia Sangrienta", icon = "racial_orc_berserkerstrength", description = "Aumenta el poder de ataque en un 6%. Dura 15 seg."},
	  Spell_2 = {name = "Mando", icon = "ability_warrior_warcry", description = "El daño infligido por las mascotas aumenta en un 5%."},
	  Spell_3 = {name = "Dureza", icon = "inv_helmet_23", description = "La duración de los aturdimientos se reduce un 15% adicional."},
	  Spell_4 = {name = "Especialización con Hachas", icon = "inv_axe_02", description = "La pericia con Armas de Puño, Hachas y Hachas de Dos Manos aumenta en 5."},
	 },
[7] = {
      Name = "No Muerto",
      Description = "Fuera del alcance del Rey Exánime, los Renegados buscan la manera de derrocarlo. El alma en pena Sylvanas lidera su sed de venganza contra la Plaga. Los humanos ahora también son el enemigo, implacables en su intento de purgar de no-muertos el mundo. A los Renegados les importan poco incluso sus aliados; para ellos, la Horda no es más que una herramienta para promover sus oscuros planes.",
	  Spell_1 = {name = "Canibalismo", icon = "ability_racial_cannibalize", description = "Al activarse, regenera un 7% de la salud total cada 2 seg durante 10 seg. Solo funciona con cadáveres humanoides o no muertos a 5 m."},
	  Spell_2 = {name = "Voluntad de los Renegados", icon = "spell_shadow_raisedead", description = "Elimina cualquier efecto de Encantamiento, Miedo o Sueño. Este efecto comparte un tiempo de reutilización de 45 seg con otros similares."},
	  Spell_3 = {name = "Resistencia a las Sombras", icon = "spell_shadow_detectinvisibility", description = "Reduce la probabilidad de ser alcanzado por hechizos de Sombras en un 2%."},
	  Spell_4 = {name = "Respiración Subacuática", icon = "spell_shadow_demonbreath", description = "La duración de la respiración bajo el agua aumenta un 233%."}, 
	 },
[8] = {
      Name = "Tauren",
	  Description = "Los tauren se esfuerzan continuamente para preservar el equilibrio de la Naturaleza y respetar los deseos de la diosa que veneran, la Madre Tierra. Hace poco fueron atacados por mortíferos centauros y habrían sido aniquilados si no hubiese sido por un encuentro fortuito con los orcos, que les ayudaron a derrotar a los intrusos. Para hacer honor a esta deuda de sangre, los tauren se unieron a la Horda, afianzando la amistad de ambas razas.",
	  Spell_1 = {name = "Pisotón de Guerra", icon = "ability_warstomp", description = "Aturde hasta 5 enemigos en un radio de 8 m durante 2 seg."},
	  Spell_2 = {name = "Resistencia", icon = "spell_nature_unyeildingstamina", description = "La salud base aumenta en un 5%."},
	  Spell_3 = {name = "Resistencia a la Naturaleza", icon = "spell_nature_spiritarmor", description = "Reduce la probabilidad de ser alcanzado por hechizos de Naturaleza en un 2%."},
	  Spell_4 = {name = "Cultivo", icon = "inv_misc_flower_01", description = "Habilidad en Herboristería aumentada en 15."},
	 },
[9] = {
      Name = "Trol",
	  Description = "Los fieros trols de la tribu Lanza Negra habitaban las junglas de la Vega de Tuercespina hasta que facciones guerreras los expulsaron de allí. Con el tiempo, los trols entablaron amistad con la Horda de los orcos y Thrall, el joven Jefe de Guerra orco, los convenció para que viajasen con él a Kalimdor. A pesar de su inherente herencia oscura, los trols de la tribu Lanza Negra ocupan un lugar privilegiado en la Horda.",
	  Spell_1 = {name = "Rabiar", icon = "racial_troll_berserk", description = "Aumenta tu velocidad de ataque y lanzamiento en un 20% durante 10 seg."},
	  Spell_2 = {name = "Regeneración", icon = "spell_nature_regenerate", description = "La tasa de regeneración de salud aumenta en un 10%. El 10% de la regeneración total continúa durante el combate."},
	  Spell_3 = {name = "Asesino de Bestias", icon = "inv_misc_pelt_bear_ruin_02", description = "El daño infligido contra Bestias aumenta en un 5%."},
	  Spell_4 = {name = "Especialización en Armas Arrojadizas", icon = "inv_throwingaxe_03", description = "Tu probabilidad de golpe crítico con armas arrojadizas aumenta en un 1%."}, 
	  Spell_5 = {name = "Especialización con Arcos", icon = "inv_weapon_bow_12", description = "Tu probabilidad de golpe crítico con Arcos aumenta en un 1%."},
	  Spell_6 = {name = "El Vudú Zalamero", icon = "inv_misc_idol_02", description = "Reduce la duración de todos los efectos que impiden el movimiento en un 15%. ¡Los trolls siempre se escapan, mon!"},
	 },
[10] = {
      Name = "Elfo de Sangre",
	  Description = "Hace mucho tiempo, los elfos nobles exiliados fundaron Quel'Thalas y allí crearon una fuente mágica, La Fuente del Sol. A pesar de que sus poderes los fortalecieron, desarrollaron una fuerte adicción a ellos.\n\nAños más tarde, la Plaga de los no-muertos destruyó La Fuente del Sol y casi la totalidad de la población de elfos nobles. Ahora, conocidos como los elfos de sangre, estos refugiados dispersos intentan reconstruir Quel'Thalas a la par que buscan una nueva fuente mágica que calme su dolorosa adicción.",
	  Spell_1 = {name = "Torrente Arcano", icon = "spell_shadow_teleport", description = "Silencia a todos los enemigos en un radio de 8 m durante 2 seg y restaura un 6% de tu maná. Además, interrumpe el lanzamiento de hechizos de objetivos que no sean jugadores durante 3 seg."},
	  Spell_2 = {name = "Afinidad Arcana", icon = "inv_enchant_shardglimmeringlarge", description = "Habilidad en Encantamiento aumentada en 10."},
	  Spell_3 = {name = "Resistencia Mágica", icon = "spell_shadow_antimagicshell", description = "Reduce la probabilidad de ser alcanzado por hechizos en un 2%."},
	 },
}

local Class_Informations = {
[1] = {
      Name = "Guerrero",
      Description = "Los guerreros son los maestros del combate cuerpo a cuerpo, capaces de usar una gran variedad de armas y armaduras. Su fuerza y resistencia los convierten en tanques formidables, capaces de proteger a sus aliados mientras infligen daño devastador a sus enemigos.",
      Roles = "Daño cuerpo a cuerpo, Tanque.",
	 },
[2] = {
      Name = "Paladín",
      Description = "Los paladines son guerreros sagrados que combinan el combate cuerpo a cuerpo con la magia divina. Dedicados a la justicia y la protección de los inocentes, pueden sanar aliados, protegerlos con bendiciones y castigar a los malvados con poder sagrado.",
      Roles = "Daño cuerpo a cuerpo, Tanque, Sanador.",
	 },
[3] = {
      Name = "Cazador",
      Description = "Los cazadores son maestros del combate a distancia y la supervivencia en la naturaleza. Acompañados por sus fieles compañeros animales, pueden rastrear enemigos, tender trampas y atacar desde la distancia con arcos y armas de fuego.",
      Roles = "Daño a distancia.",
	 },
[4] = {
      Name = "Pícaro",
      Description = "Los pícaros son maestros del sigilo y el engaño, capaces de moverse sin ser detectados y atacar desde las sombras. Su agilidad y destreza les permiten infligir daño crítico letal, mientras evitan los ataques enemigos con movimientos ágiles.",
      Roles = "Daño cuerpo a cuerpo.",
	 },
[5] = {
      Name = "Sacerdote",
      Description = "Los sacerdotes son maestros de la magia divina, dedicados a sanar y proteger a sus aliados. Aunque también pueden canalizar poderes sombríos, su verdadera fuerza radica en su capacidad para restaurar la vida y brindar protección espiritual.",
      Roles = "Daño a distancia, Sanador.",
	 },
[6] = {
      Name = "Caballero de la Muerte",
      Description = "Los caballeros de la muerte son guerreros no muertos que han dominado las artes necrománticas. Una vez sirvientes del Rey Exánime, ahora luchan con su propia voluntad, combinando habilidades marciales con magia sombría y poderes sobre la muerte.",
      Roles = "Daño cuerpo a cuerpo, Tanque.",
	  },
[7] = {
      Name = "Chamán",
      Description = "Los chamanes son intermediarios entre el mundo espiritual y el físico, capaces de canalizar los elementos y comunicarse con los espíritus. Pueden sanar a sus aliados, invocar tótems poderosos y desatar la furia de los elementos sobre sus enemigos.",
      Roles = "Daño cuerpo a cuerpo, Daño a distancia, Sanador.",
	  },
[8] = {
      Name = "Mago",
      Description = "Los magos son maestros de las artes arcanas, capaces de canalizar poderosos hechizos elementales. Aunque frágiles físicamente, su dominio de la magia los convierte en una fuerza devastadora en el campo de batalla, capaces de controlar el hielo, el fuego y las fuerzas arcanas.",
      Roles = "Daño a distancia.",
	  },
[9] = {
      Name = "Brujo",
      Description = "Los brujos han hecho pactos con fuerzas demoníacas para obtener poder. Maestros de la magia sombría y vil, pueden invocar demonios, drenar la vida de sus enemigos y canalizar energías corruptoras para devastar el campo de batalla.",
      Roles = "Daño a distancia.",
	  },
[10] = {
      Name = "Druida",
      Description = "Los druidas son guardianes de la naturaleza, capaces de transformarse en diferentes formas animales. Su versatilidad les permite cumplir múltiples roles: pueden sanar como sacerdotes, tanquear como guerreros, o infligir daño como magos, todo mientras mantienen su conexión con el mundo natural.",
      Roles = "Daño cuerpo a cuerpo, Daño a distancia, Tanque, Sanador.",
      },
};

local RaceTooltipPositions = {
    Alliance = {
        [1] = { -- Humano
            high = {point = "TOPLEFT", relPoint = "TOPRIGHT", x = 20, y = 20},
            low = {point = "BOTTOMLEFT", relPoint = "TOPRIGHT", x = 20, y = -80},
            veryLow = {point = "BOTTOMLEFT", relPoint = "TOPRIGHT", x = 20, y = -180},
            default = {point = "LEFT", relPoint = "RIGHT", x = 20, y = 0}
        },
        [2] = { -- Enano
            high = {point = "TOPLEFT", relPoint = "TOPRIGHT", x = 20, y = 40},
            low = {point = "BOTTOMLEFT", relPoint = "TOPRIGHT", x = 20, y = -60},
            veryLow = {point = "BOTTOMLEFT", relPoint = "TOPRIGHT", x = 20, y = -140},
            default = {point = "LEFT", relPoint = "RIGHT", x = 20, y = 20}
        },
        [3] = { -- Elfo de la noche
            high = {point = "TOPLEFT", relPoint = "TOPRIGHT", x = 20, y = 20},
            low = {point = "BOTTOMLEFT", relPoint = "TOPRIGHT", x = 20, y = -80},
            veryLow = {point = "BOTTOMLEFT", relPoint = "TOPRIGHT", x = 20, y = -180},
            default = {point = "LEFT", relPoint = "RIGHT", x = 20, y = 0}
        },
        [4] = { -- Gnomo
            high = {point = "TOPLEFT", relPoint = "TOPRIGHT", x = 20, y = 40},
            low = {point = "BOTTOMLEFT", relPoint = "TOPRIGHT", x = 20, y = -60},
            veryLow = {point = "BOTTOMLEFT", relPoint = "TOPRIGHT", x = 20, y = -140},
            default = {point = "LEFT", relPoint = "RIGHT", x = 20, y = 20}
        },
        [5] = { -- Draenei
            high = {point = "TOPLEFT", relPoint = "TOPRIGHT", x = 20, y = 20},
            low = {point = "BOTTOMLEFT", relPoint = "TOPRIGHT", x = 20, y = -80},
            veryLow = {point = "BOTTOMLEFT", relPoint = "TOPRIGHT", x = 20, y = -180},
            default = {point = "LEFT", relPoint = "RIGHT", x = 20, y = 0}
        }
    },
    Horde = {
        [6] = { -- Orco
            high = {point = "TOPRIGHT", relPoint = "TOPLEFT", x = -20, y = 20},
            veryLow = {point = "BOTTOMRIGHT", relPoint = "TOPLEFT", x = -20, y = -120},
            default = {point = "RIGHT", relPoint = "LEFT", x = -20, y = 0}
        },
        [7] = { -- No-muerto
            high = {point = "TOPRIGHT", relPoint = "TOPLEFT", x = -20, y = 40},
            veryLow = {point = "BOTTOMRIGHT", relPoint = "TOPLEFT", x = -20, y = -80},
            default = {point = "RIGHT", relPoint = "LEFT", x = -20, y = 20}
        },
        [8] = { -- Tauren
            high = {point = "TOPRIGHT", relPoint = "TOPLEFT", x = -20, y = 20},
            veryLow = {point = "BOTTOMRIGHT", relPoint = "TOPLEFT", x = -20, y = -120},
            default = {point = "RIGHT", relPoint = "LEFT", x = -20, y = 0}
        },
        [9] = { -- Trol
            high = {point = "TOPRIGHT", relPoint = "TOPLEFT", x = -20, y = 40},
            veryLow = {point = "BOTTOMRIGHT", relPoint = "TOPLEFT", x = -20, y = -80},
            default = {point = "RIGHT", relPoint = "LEFT", x = -20, y = 20}
        },
        [10] = { -- Elfo de sangre
            high = {point = "TOPRIGHT", relPoint = "TOPLEFT", x = -20, y = 20},
            veryLow = {point = "BOTTOMRIGHT", relPoint = "TOPLEFT", x = -20, y = -120},
            default = {point = "RIGHT", relPoint = "LEFT", x = -20, y = 0}
        }
    }
}

function GetRaceTooltipPosition(raceID, button)
    local screenHeight = GetScreenHeight()
    local buttonTop = button:GetTop()
    local buttonBottom = button:GetBottom()

    local faction = raceID <= 5 and "Alliance" or "Horde"
    local positions = RaceTooltipPositions[faction][raceID]
    
    if not positions then
        return {point = "CENTER", relPoint = "CENTER", x = 0, y = 0}
    end

    if buttonTop > screenHeight * 0.66 then
        return positions.high
    elseif buttonBottom < screenHeight * 0.44 and positions.low then
        return positions.low
    elseif buttonBottom < screenHeight * 0.33 and positions.veryLow then
        return positions.veryLow
    else
        return positions.default
    end
end

_G.RACE_1 = "Humano"
_G.RACE_2 = "Enano"
_G.RACE_3 = "Elfo de la noche"
_G.RACE_4 = "Gnomo"
_G.RACE_5 = "Draenei"
_G.RACE_6 = "Orco"
_G.RACE_7 = "No-muerto"
_G.RACE_8 = "Tauren"
_G.RACE_9 = "Trol"
_G.RACE_10 = "Elfo de sangre"

_G.Races_Informations = Races_Informations
_G.Class_Informations = Class_Informations
_G.ClassRaces = ClassRaces
_G.GetRaceTooltipPosition = GetRaceTooltipPosition
