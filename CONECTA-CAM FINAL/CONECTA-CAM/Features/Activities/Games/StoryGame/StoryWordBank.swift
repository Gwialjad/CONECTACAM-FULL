//
//  StoryWordBank.swift
//  Conecta CAM
//
//  Banco de palabras de "Historia en cadena".
//
//  Las palabras están agrupadas por función (comienzos, personajes, acciones...).
//  En cada turno se reparte una "mano" de 10 palabras con un poco de cada grupo
//  (ver StoryWordDeck.swift), así las frases se pueden armar casi sin esfuerzo
//  y cada historia sale distinta.
//
//  Para agregar palabras: solo añade textos a la lista del grupo que corresponda.
//  Reglas para que las frases suenen bien al juntarlas:
//    - Personajes: sujetos en singular ("un perro", "la tortuga").
//    - Acciones: verbo en pasado, tercera persona singular ("encontró").
//    - Formas de hacerlo: sin género ("con alegría", no "contento").
//    - No repitas un texto en dos grupos.
//

import Foundation

/// Tipos de palabra, en el orden en que suelen aparecer dentro de una frase.
enum StoryWordKind: CaseIterable, Hashable {
    case opening   // comienzos y conectores: "Un día", "De repente"
    case who       // personajes: "mi abuela", "la rana"
    case action    // acciones: "encontró", "bailó"
    case thing     // cosas: "un tesoro", "una cometa"
    case place     // lugares: "en el bosque"
    case manner    // cómo: "con alegría", "muy despacio"
    case talk      // para platicar: "HOLA", "¿Qué piensas?"
}

struct StoryWord: Identifiable, Hashable {
    let text: String
    let kind: StoryWordKind
    /// El texto es único en todo el banco, así que sirve como identificador.
    var id: String { text }
}

enum StoryWordBank {

    /// Cuántas palabras de cada tipo salen en cada turno (suman 10: dos filas de cinco).
    static let handRecipe: [(kind: StoryWordKind, count: Int)] = [
        (.opening, 2),
        (.who, 2),
        (.action, 2),
        (.thing, 1),
        (.place, 1),
        (.manner, 1),
        (.talk, 1)
    ]

    static func words(of kind: StoryWordKind) -> [StoryWord] {
        all[kind] ?? []
    }

    /// Total de palabras en el banco (útil para revisar al agregar más).
    static var totalCount: Int { all.values.reduce(0) { $0 + $1.count } }

    // MARK: - Datos

    private static let all: [StoryWordKind: [StoryWord]] = {
        var result: [StoryWordKind: [StoryWord]] = [:]
        var seen = Set<String>()
        for kind in StoryWordKind.allCases {
            // Si un texto se repite por error, solo se queda la primera vez.
            result[kind] = (raw[kind] ?? []).compactMap { text in
                seen.insert(text).inserted ? StoryWord(text: text, kind: kind) : nil
            }
        }
        return result
    }()

    private static let raw: [StoryWordKind: [String]] = [

        .opening: [
            "Había una vez", "Una vez", "Un día", "Ayer", "Hoy", "Mañana",
            "Cuando era", "Cuando era joven", "Hace mucho tiempo", "Una mañana",
            "Una tarde", "Una noche", "Esa noche", "De repente", "Entonces",
            "Después", "Luego", "Mientras tanto", "Por eso", "Al final",
            "Por fin", "Pero", "Y", "Porque", "También", "Primero",
            "Todos los días", "Un fin de semana", "En vacaciones", "Más tarde",
            "Al día siguiente", "Recuerdo que", "Me acuerdo de"
        ],

        .who: [
            "un perro", "una gata", "mi mamá", "mi papá", "mi abuela", "mi abuelo",
            "mi hermano", "mi hermana", "mi mejor amigo", "mi mejor amiga",
            "mi maestra", "mi maestro", "un niño", "una niña", "un dragón",
            "un robot", "un pirata", "un payaso", "un osito", "una vaca",
            "un pajarito", "un astronauta", "un hada", "un gigante", "un cocinero",
            "un mago", "un conejo", "un dinosaurio", "una ranita", "un pez",
            // Los personajes de la pantalla "Elige a tu amigo":
            "la oveja", "el caracol", "el pulpo", "la abeja", "el elefante",
            "la tortuga", "el cerdito", "la rana", "el gato", "la jirafa",
            "el dino", "el koala"
        ],

        .action: [
            "corrió", "saltó", "encontró", "cantó", "bailó", "jugó", "comió",
            "dibujó", "voló", "nadó", "abrazó", "ayudó", "se escondió", "se rió",
            "pintó", "construyó", "buscó", "viajó", "descubrió", "preparó",
            "visitó", "aprendió", "compartió", "escuchó", "miró", "caminó",
            "durmió", "gritó de alegría", "trepó", "lanzó", "atrapó", "cocinó",
            "regaló", "sonrió", "soñó", "montó", "subió", "bajó", "abrió", "llevó"
        ],

        .thing: [
            "un tesoro", "una pelota", "un pastel", "un mapa", "una cometa",
            "un libro", "una flor", "un helado", "una guitarra", "un globo",
            "un regalo", "una llave", "una estrella", "un sombrero", "una bicicleta",
            "un cohete", "una piñata", "un paraguas", "una carta", "un dibujo",
            "una canción", "un cuento", "una sorpresa", "una manzana", "una galleta",
            "un tambor", "un barco de papel", "una linterna", "una mochila",
            "un arcoíris", "una piedra brillante", "un juguete", "un trompo",
            "una nube", "un espejo"
        ],

        .place: [
            "en el bosque", "en la escuela", "en la playa", "en mi casa",
            "en el parque", "en el mar", "en la montaña", "en el jardín",
            "en la cocina", "en una cueva", "en la ciudad", "en el campo",
            "en la granja", "en el cielo", "en el circo", "en la biblioteca",
            "en el mercado", "en la luna", "en un barco", "en un castillo",
            "en el salón", "en el patio", "en la fiesta", "en el zoológico",
            "en la selva", "en el río", "en el lago", "en la nieve",
            "en el desierto", "en el cine", "en la tienda", "en el tren",
            "en el autobús", "en una isla"
        ],

        .manner: [
            "con alegría", "con mucha emoción", "con sueño", "con curiosidad",
            "con calma", "con sorpresa", "con valentía", "con orgullo",
            "con hambre", "con cuidado", "con cariño", "con paciencia",
            "sin parar", "muy rápido", "muy despacio", "todo el día", "otra vez",
            "juntos", "en silencio", "a carcajadas", "de puntitas", "de un salto",
            "con una sonrisa", "con mucha fuerza", "al mismo tiempo",
            "poco a poco", "sin miedo", "con ayuda", "a su manera"
        ],

        .talk: [
            "HOLA", "¿Qué piensas?", "Por ejemplo...", "¡Qué divertido!",
            "¡Gracias!", "¿Y tú?", "¡Mira!", "¡Vamos!", "Me gusta...", "No sé",
            "¡Sí!", "Recuerdo...", "¡Qué bonito!", "¡Increíble!", "¿Te acuerdas?",
            "¡Hola, amigos!", "¡Buen trabajo!", "¡Wow!", "¡Ayúdame!", "¡Cuidado!",
            "¿Quieres jugar?", "¡Qué rico!", "¡Qué risa!", "Es mi favorito",
            "¿Cómo te llamas?", "Me encanta", "¡Feliz cumpleaños!", "¡Adiós!",
            "¡Bravo!", "¡Eso es!", "Ahora tú", "¿Qué sigue?"
        ]
    ]
}
