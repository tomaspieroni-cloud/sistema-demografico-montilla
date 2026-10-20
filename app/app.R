library(shiny)
library(DBI)
library(RPostgres)
library(dplyr)
library(ggplot2)
library(stringr)
library(plotly)

etiquetas_indicadores <- c(
  a01 = "Extensión superficial",
  b01 = "Población total",
  b02 = "Población. Hombres",
  b03 = "Población. Mujeres",
  b04 = "Población en núcleos",
  b05 = "Población en diseminados",
  b06 = "Porcentaje de población menor de 20 años",
  b07 = "Porcentaje de población mayor de 65 años",
  b08 = "Variación relativa de la población en diez años",
  b09 = "Número de extranjeros",
  b10 = "Principal procedencia de los extranjeros residentes",
  b11 = "Porcentaje respecto al total de extranjeros",
  b12 = "Emigraciones",
  b13 = "Inmigraciones",
  b14 = "Nacimientos",
  b15 = "Defunciones",
  b16 = "Matrimonios",
  b17 = "Edad media",
  saldo_natural = "Saldo vegetativo",
  densidad = "Densidad de población"
)

etiquetar_indicador <- function(codigo) {
  etiqueta <- unname(etiquetas_indicadores[codigo])
  ifelse(is.na(etiqueta), codigo, etiqueta)
}

etiquetar_fuente <- function(x) {
  dplyr::recode(
    x,
    IECA = "IECA",
    INE = "INE",
    INE_Padron = "INE - Padrón",
    INE_Censo = "INE - Censo",
    INE_serie = "INE serie",
    SIMA = "SIMA",
    Derivado = "Derivado",
    .default = x
  )
}

ind_check_choices <- c(
  "Población total (b01)" = "b01",
  "Población. Hombres (b02)" = "b02",
  "Población. Mujeres (b03)" = "b03",
  "Población en núcleos (b04)" = "b04",
  "Población en diseminados (b05)" = "b05",
  "Porcentaje población menor de 20 años (b06)" = "b06",
  "Porcentaje población mayor de 65 años (b07)" = "b07",
  "Variación relativa población 10 años (b08)" = "b08"
)

# -------------------------------
# Conexión a PostgreSQL
# Se centraliza la conexión para evitar repetir credenciales.
# -------------------------------
conectar_db <- function() {
  dbname <- Sys.getenv("DB_NAME", "montilla_db")
  user <- Sys.getenv("DB_USER", "montilla_user")
  password <- Sys.getenv("DB_PASS", "montilla_pass")

  host_env <- Sys.getenv("DB_HOST", "")
  port_env <- suppressWarnings(as.integer(Sys.getenv("DB_PORT", "")))

  candidatos <- list(
    list(host = host_env, port = port_env),
    list(host = "127.0.0.1", port = 5433),
    list(host = "localhost", port = 5433),
    list(host = "127.0.0.1", port = 5432),
    list(host = "localhost", port = 5432)
  )

  for (candidato in candidatos) {
    if (is.na(candidato$port) || !nzchar(candidato$host)) {
      next
    }

    conexion <- tryCatch(
      dbConnect(
        RPostgres::Postgres(),
        dbname = dbname,
        host = candidato$host,
        port = candidato$port,
        user = user,
        password = password
      ),
      error = function(e) NULL
    )

    if (!is.null(conexion)) {
      return(conexion)
    }
  }

  stop(
    "No se pudo conectar a PostgreSQL. Verificá DB_HOST/DB_PORT o que el contenedor esté levantado. "
  )
}

# -------------------------------
# Lectura SQL
# La función ejecuta consultas SQL y cierra la conexión al terminar.
# -------------------------------
leer_tabla <- function(query) {
  con <- conectar_db()
  on.exit(dbDisconnect(con), add = TRUE)
  dbGetQuery(con, query)
}

# -------------------------------
# UI
# -------------------------------
ui <- fluidPage(
  titlePanel("Demografía Montilla – Dashboard"),
  # Botón global de exportación
  fluidRow(
    column(12, downloadButton("download_zip_final", "Descargar paquete (ZIP)"))
  ),
  br(),
  
  
  tabsetPanel(
    
    tabPanel(
      "Tabla final (check)",
      selectInput("ind_check", "Indicador:", choices = ind_check_choices, selected = "b02"),
      tableOutput("tabla_check")
    ),
    
    tabPanel(
      "Envejecimiento",
      helpText("Se muestran ambas fuentes en el solape para comparación (IECA/INE)."),
      plotlyOutput("plot_envejecimiento", height = "450px"),
      plotlyOutput("plot_envejecimiento_forecast", height = "450px")
    ),
    
    tabPanel(
      "Dependencia",
      helpText("Se muestra IECA (dependencia global) e INE en el periodo disponible."),
      plotlyOutput("plot_dependencia", height = "450px")
    ),
    
    tabPanel(
      "Edad media (sexo)",
      checkboxGroupInput(
        "sexo_em",
        "Sexo:",
        choices = c("Hombres", "Mujeres", "Total"),
        selected = c("Hombres", "Mujeres", "Total"),
        inline = TRUE
      ),
      helpText("Se excluyen valores faltantes automáticamente."),
      plotlyOutput("plot_edad_media", height = "450px")
    ),
    
    tabPanel(
      "Atracción (jóvenes + migración)",
      checkboxGroupInput(
        "fuente_joven",
        "Fuente jóvenes (INE):",
        choices = c("INE_Padron", "INE_Censo"),
        selected = c("INE_Padron", "INE_Censo"),
        inline = TRUE
      ),
      checkboxGroupInput(
        "fuente_mig",
        "Fuente migración:",
        choices = c("IECA", "INE"),
        selected = c("IECA", "INE"),
        inline = TRUE
      ),
      plotlyOutput("plot_joven", height = "350px"),
      plotlyOutput("plot_saldo", height = "350px"),
      plotlyOutput("plot_inmigraciones_emigraciones", height = "350px"),
      plotlyOutput("plot_tasa", height = "350px")
    ),
    
    tabPanel(
      "Pirámide",
      helpText("Se representa Hombres en negativo y Mujeres en positivo. Si el año tiene solape (2021–2022), se pueden ver ambas fuentes."),
      fluidRow(
        column(4, selectInput("anio_piramide", "Año:", choices = NULL)),
        column(8,
               checkboxGroupInput(
                 "fuente_piramide",
                 "Fuente:",
                 choices = c("INE_Padron", "INE_Censo"),
                 selected = c("INE_Padron", "INE_Censo"),
                 inline = TRUE
               )
        )
      ),
      plotlyOutput("plot_piramide", height = "520px")
    ),
    
    tabPanel(
      "Paro registrado",
      checkboxGroupInput(
        "sexo_paro",
        "Sexo:",
        choices = c("Hombres", "Mujeres", "Ambos sexos"),
        selected = c("Hombres", "Mujeres"),
        inline = TRUE
      ),
      helpText("Demandantes de empleo registrados (2009–2025)."),
      plotlyOutput("plot_paro", height = "450px")
    ),
    
    tabPanel(
      "Crecimiento natural",
      helpText("Comparación anual: nacimientos (verde) vs defunciones (rojo). Muestra el balance natural de población."),
      plotlyOutput("plot_crecimiento_natural", height = "450px")
    )
    
  ) 
) 

# -------------------------------
# SERVER
# -------------------------------

server <- function(input, output, session) {
  output$download_zip_final <- downloadHandler(
    filename = function() {
      paste0("montilla_paquete_", format(Sys.Date(), "%Y%m%d"), ".zip")
    },
    content = function(file) {
      
      tmpdir <- tempfile("montilla_export_")
      dir.create(tmpdir)
      
      # 1) CSV tabla final
      df_final <- leer_tabla("
      SELECT cod_ine, municipio, anio, bloque, indicador_id, indicador_nombre, unidad, fuente, valor, valor_texto
      FROM montilla_indicadores_migracion_fix
      ORDER BY anio, bloque, indicador_id, fuente;
    ")
      csv_final <- file.path(tmpdir, paste0("montilla_indicadores_final_long_", format(Sys.Date(), "%Y%m%d"), ".csv"))
      write.csv(df_final, csv_final, row.names = FALSE, fileEncoding = "UTF-8")
      
      # 2) CSV diccionario (si no existe, cortar con error claro)
      df_dic <- leer_tabla("SELECT * FROM dim_indicador_sima ORDER BY indicador_id;")
      csv_dic <- file.path(tmpdir, "dim_indicador_sima.csv")
      write.csv(df_dic, csv_dic, row.names = FALSE, fileEncoding = "UTF-8")
      
      # 3) README
      readme <- file.path(tmpdir, "README_metodologia.txt")
      txt <- c(
        "Proyecto Montilla – Paquete de datos",
        paste0("Generado: ", format(Sys.time(), "%Y-%m-%d %H:%M:%S")),
        "",
        "Incluye:",
        "- montilla_indicadores_final_long_YYYYMMDD.csv",
        "- dim_indicador_sima.csv",
        "- README_metodologia.txt",
        "",
        "Notas:",
        "1) Puede haber duplicados por fuente (SIMA vs INE_serie) en un mismo anio/indicador.",
        "2) b08 (variación 10 años) es NA en los primeros 10 años por ventana t-10.",
        "3) Indicadores textuales (ej. b10) se guardan en valor_texto."
      )
      writeLines(enc2utf8(txt), readme)
      
      # Requiere paquete zip (más robusto que utils::zip en Windows)
      zip::zipr(
        zipfile = file,
        files   = c(csv_final, csv_dic, readme)
      )
    },
    contentType = "application/zip"
  )
  # ------------------------------------------------------------
  # Envejecimiento: IECA + INE (solape visible)
  # ------------------------------------------------------------
  envejecimiento <- reactive({
    leer_tabla("
      SELECT anio, indice_envejecimiento, 'IECA' AS fuente
      FROM indice_envejecimiento_ieca
      UNION ALL
      SELECT anio, indice_envejecimiento, 'INE' AS fuente
      FROM indice_envejecimiento_ine
      ORDER BY anio, fuente;
    ")
  })
  envejecimiento_forecast <- reactive({
    leer_tabla("
    SELECT anio, fuente_modelo, metodo, tipo, valor, lo80, hi80, lo95, hi95
    FROM indice_envejecimiento_forecast_2032
    ORDER BY anio;
  ")
  })
  
  # ------------------------------------------------------------
  # Dependencia: IECA (global) + INE
  # ------------------------------------------------------------
  dependencia <- reactive({
    leer_tabla("
      SELECT anio, indice_dependencia, 'IECA' AS fuente
      FROM indice_dependencia_ieca
      WHERE tipo = 'Índice de dependencia global'
      UNION ALL
      SELECT anio, indice_dependencia, 'INE' AS fuente
      FROM indice_dependencia_ine
      ORDER BY anio, fuente;
    ")
  })
  
  # ------------------------------------------------------------
  # Edad media por sexo
  # ------------------------------------------------------------
  edad_media <- reactive({
    leer_tabla("
      SELECT anio, sexo, edad_media, fuente
      FROM edad_media_sexo_montilla
      WHERE edad_media IS NOT NULL
      ORDER BY anio, sexo;
    ")
  })
  
  # ------------------------------------------------------------
  # Jóvenes: comparación Padrón vs Censo (solape 2021–2022)
  # ------------------------------------------------------------
  joven_comp <- reactive({
    tryCatch({
      leer_tabla("
        SELECT anio, poblacion_joven, poblacion_total, porcentaje_joven, 'INE_Padron' AS fuente
        FROM poblacion_joven_ine_2003_2022
        UNION ALL
        SELECT anio, poblacion_joven, poblacion_total, porcentaje_joven, 'INE_Censo' AS fuente
        FROM poblacion_joven_ine_2021_2025
        ORDER BY anio, fuente;
      ")
    }, error = function(e) {
      data.frame(anio=integer(), poblacion_joven=double(), poblacion_total=double(),
                 porcentaje_joven=double(), fuente=character())
    })
  })
  
  # ------------------------------------------------------------
  # Saldo migratorio: comparación IECA vs INE (solape 2021)
  # ------------------------------------------------------------
  saldo_comp <- reactive({
    tryCatch({
      leer_tabla("
        SELECT anio, saldo_migratorio, fuente
        FROM saldo_migratorio_comparativa
        ORDER BY anio, fuente;
      ")
    }, error = function(e) {
      data.frame(anio=integer(), saldo_migratorio=double(), fuente=character())
    })
  })
  
  # ------------------------------------------------------------
  # Tasa por 1.000: comparación IECA vs INE (solape 2021)
  # ------------------------------------------------------------
  tasa_comp <- reactive({
    tryCatch({
      leer_tabla("
        SELECT anio, tasa_saldo_1000, fuente
        FROM tasa_saldo_migratorio_comparativa
        ORDER BY anio, fuente;
      ")
    }, error = function(e) {
      data.frame(anio=integer(), tasa_saldo_1000=double(), fuente=character())
    })
  })
  
  # ------------------------------------------------------------
  # Pirámide: carga de años disponibles para el selector
  # ------------------------------------------------------------
  observe({
    anios <- tryCatch({
      leer_tabla("
      SELECT DISTINCT anio
      FROM poblacion_edad_sexo_ine_comparativa
      ORDER BY anio;
    ")$anio
    }, error = function(e) integer())
    
    if (length(anios) > 0) {
      updateSelectInput(session, "anio_piramide", choices = anios, selected = max(anios))
    }
  })
  
  # ------------------------------------------------------------
  # Pirámide: datos filtrados por año y fuente
  # ------------------------------------------------------------
  piramide_data <- reactive({
    req(input$anio_piramide)
    req(input$fuente_piramide)
    
    df <- leer_tabla(sprintf("
      SELECT anio, fuente, sexo, grupo_edad, edad_min, poblacion
      FROM poblacion_edad_sexo_ine_comparativa
      WHERE anio = %s
        AND fuente IN ('%s')
      ORDER BY fuente, sexo, edad_min;
    ",
                             as.integer(input$anio_piramide),
                             paste(input$fuente_piramide, collapse = "','")
    ))
    
    df
  })
  
  # -------------------------------
  # Plot: Envejecimiento
  # -------------------------------
  output$plot_envejecimiento <- renderPlotly({
    plotly::ggplotly({
    df <- envejecimiento()
    y_top <- max(df$indice_envejecimiento, na.rm = TRUE)
    
    ggplot(df, aes(x = anio, y = indice_envejecimiento, color = fuente)) +
      geom_line(linewidth = 1.1) +
      geom_point(size = 2) +
      scale_color_discrete(labels = etiquetar_fuente) +
      scale_x_continuous(expand = expansion(mult = c(0.02, 0.14))) +
      labs(x = "A\u00f1o", y = "Índice de envejecimiento", color = "Fuente") +
        theme_minimal() +
        theme(plot.margin = margin(5.5, 28, 5.5, 5.5)) +
      geom_vline(xintercept = 2021.5, linetype = "dashed") +
      annotate("text", x = 2021.5, y = y_top, label = "Solape 2021", vjust = -0.5, angle = 90)
    }, tooltip = c("x", "y", "colour"))
  })
  
  # -------------------------------
  # Plot: Dependencia
  # -------------------------------
  output$plot_dependencia <- renderPlotly({
    plotly::ggplotly({
    df <- dependencia()
    y_top <- max(df$indice_dependencia, na.rm = TRUE)
    
    ggplot(df, aes(x = anio, y = indice_dependencia, color = fuente)) +
      geom_line(linewidth = 1.1) +
      geom_point(size = 2) +
      scale_color_discrete(labels = etiquetar_fuente) +
      scale_x_continuous(expand = expansion(mult = c(0.02, 0.14))) +
      labs(x = "A\u00f1o", y = "Índice de dependencia (global)", color = "Fuente") +
        theme_minimal() +
        theme(plot.margin = margin(5.5, 28, 5.5, 5.5)) +
      geom_vline(xintercept = 2021.5, linetype = "dashed") +
      annotate("text", x = 2021.5, y = y_top, label = "Solape 2021", vjust = -0.5, angle = 90)
    }, tooltip = c("x", "y", "colour"))
  })
  
  # -------------------------------
  # Plot: Edad media
  # -------------------------------
  output$plot_edad_media <- renderPlotly({
    plotly::ggplotly({
    df <- edad_media() %>% filter(sexo %in% input$sexo_em)
    
    ggplot(df, aes(x = anio, y = edad_media, color = sexo)) +
      geom_line(linewidth = 1.1) +
      geom_point(size = 2) +
      scale_x_continuous(expand = expansion(mult = c(0.02, 0.14))) +
      labs(x = "A\u00f1o", y = "Edad media (años)", color = "Sexo") +
        theme_minimal() +
        theme(plot.margin = margin(5.5, 28, 5.5, 5.5))
    }, tooltip = c("x", "y", "colour"))
  })
  
  # -------------------------------
  # Plot: % jóvenes
  # -------------------------------
  output$plot_joven <- renderPlotly({
    plotly::ggplotly({
    df <- joven_comp() %>% filter(fuente %in% input$fuente_joven)
    
    validate(need(nrow(df) > 0, "No hay datos de jóvenes en la base (faltan tablas en PostgreSQL)."))
    
    ggplot(df, aes(x = anio, y = porcentaje_joven, color = fuente)) +
      geom_line(linewidth = 1.1) +
      geom_point(size = 2) +
      scale_color_discrete(labels = etiquetar_fuente) +
      scale_x_continuous(expand = expansion(mult = c(0.02, 0.14))) +
      labs(title = "Porcentaje de población joven (15–29)", x = "A\u00f1o", y = "% jóvenes", color = "Fuente") +
        theme_minimal() +
        theme(plot.margin = margin(5.5, 28, 5.5, 5.5)) +
      geom_vline(xintercept = 2021.5, linetype = "dashed")
    }, tooltip = c("x", "y", "colour"))
  })
  
  # -------------------------------
  # Plot: Saldo migratorio
  # -------------------------------
  output$plot_saldo <- renderPlotly({
    plotly::ggplotly({
    df <- saldo_comp() %>% filter(fuente %in% input$fuente_mig)
    
    validate(
      need(nrow(df) > 0, "No hay datos de saldo migratorio (falta tabla comparativa en PostgreSQL).")
    )
    
    y_top <- max(df$saldo_migratorio, na.rm = TRUE)
    
    ggplot(df, aes(x = anio, y = saldo_migratorio, color = fuente)) +
      geom_hline(yintercept = 0, linetype = "dashed") +
      geom_line(linewidth = 1.1) +
      geom_point(size = 2) +
      scale_color_discrete(labels = etiquetar_fuente) +
      scale_x_continuous(expand = expansion(mult = c(0.02, 0.14))) +
      labs(
        title = "Saldo migratorio anual (personas)",
        x = "A\u00f1o",
        y = "Saldo migratorio",
        color = "Fuente"
      ) +
      theme_minimal() +
      theme(plot.margin = margin(5.5, 28, 5.5, 5.5)) +
      geom_vline(xintercept = 2021.5, linetype = "dashed") +
      annotate(
        "text",
        x = 2021.5,
        y = y_top,
        label = "Solape 2021",
        vjust = -0.5,
        angle = 90
      )
    }, tooltip = c("x", "y", "colour"))
  })
  
  # -------------------------------
  # Plot: Tasa por 1.000
  # -------------------------------
  output$plot_tasa <- renderPlotly({
    plotly::ggplotly({
    df <- tasa_comp() %>% filter(fuente %in% input$fuente_mig)
    
    validate(
      need(nrow(df) > 0, "No hay datos de tasa (falta tabla tasa_saldo_migratorio_comparativa en PostgreSQL).")
    )
    
    y_top <- max(df$tasa_saldo_1000, na.rm = TRUE)
    
    ggplot(df, aes(x = anio, y = tasa_saldo_1000, color = fuente)) +
      geom_hline(yintercept = 0, linetype = "dashed") +
      geom_line(linewidth = 1.1) +
      geom_point(size = 2) +
      scale_color_discrete(labels = etiquetar_fuente) +
      scale_x_continuous(expand = expansion(mult = c(0.02, 0.14))) +
      labs(
        title = "Saldo migratorio anual (por 1.000 habitantes)",
        x = "A\u00f1o",
        y = "Saldo por 1.000",
        color = "Fuente"
      ) +
      theme_minimal() +
      theme(plot.margin = margin(5.5, 28, 5.5, 5.5)) +
      geom_vline(xintercept = 2021.5, linetype = "dashed") +
      annotate(
        "text",
        x = 2021.5,
        y = y_top,
        label = "Solape 2021",
        vjust = -0.5,
        angle = 90
      )
    }, tooltip = c("x", "y", "colour"))
  })
  output$plot_envejecimiento_forecast <- renderPlotly({
    plotly::ggplotly({
    df_fc <- envejecimiento_forecast()
    validate(need(nrow(df_fc) > 0, "No hay datos en indice_envejecimiento_forecast_2032."))

    df_fc <- df_fc %>%
      mutate(serie = ifelse(stringr::str_detect(stringr::str_to_lower(tipo), "pred"), "predicho", "observado"))
    
    # Fuente usada para modelar (IECA o INE) y cuál es la de contraste
    fuente_modelo <- df_fc$fuente_modelo[1]
    fuente_contraste <- ifelse(fuente_modelo == "INE", "IECA", "INE")
    
    # Cargar serie de contraste desde la tabla correspondiente
    df_contraste <- if (fuente_contraste == "IECA") {
      leer_tabla("
      SELECT anio, indice_envejecimiento AS valor
      FROM indice_envejecimiento_ieca
      WHERE indice_envejecimiento IS NOT NULL
      ORDER BY anio;
    ") %>% mutate(fuente = "IECA")
    } else {
      leer_tabla("
      SELECT anio, indice_envejecimiento AS valor
      FROM indice_envejecimiento_ine
      WHERE indice_envejecimiento IS NOT NULL
      ORDER BY anio;
    ") %>% mutate(fuente = "INE")
    }
    
    ggplot() +
      # Banda de incertidumbre (80%) solo para predicho
      geom_ribbon(
        data = df_fc %>% dplyr::filter(serie == "predicho"),
        aes(x = anio, ymin = lo80, ymax = hi80),
        alpha = 0.2
      ) +
      # Serie modelo (observado + predicho)
      geom_line(
        data = df_fc,
        aes(x = anio, y = valor, color = serie),
        linewidth = 1.1
      ) +
      geom_point(
        data = df_fc,
        aes(x = anio, y = valor, color = serie),
        size = 2
      ) +
      # Contraste punteado
      geom_line(
        data = df_contraste,
        aes(x = anio, y = valor),
        inherit.aes = FALSE,
        linetype = "dashed",
        linewidth = 0.9,
        color = "gray40"
      ) +
      scale_color_manual(
        values = c(observado = "#2c7fb8", predicho = "#d95f0e"),
        labels = c(observado = "Observado", predicho = "Predicción"),
        name = "Serie"
      ) +
      scale_x_continuous(expand = expansion(mult = c(0.02, 0.14))) +
      labs(
        title = "Índice de envejecimiento observado y proyectado hasta 2032",
        x = "A\u00f1o",
        y = "Índice de envejecimiento",
        color = "Serie"
      ) +
      theme_minimal()
    }, tooltip = c("x", "y", "colour"))
  })
  output$tabla_check <- renderTable({
    req(input$ind_check)
    
    df <- leer_tabla(sprintf("
    SELECT anio, indicador_id, indicador_nombre, fuente, valor, valor_texto
    FROM montilla_indicadores_migracion_fix
    WHERE cod_ine = 14042 AND indicador_id = '%s'
    ORDER BY anio, fuente;
  ", input$ind_check))
    
    df %>%
      mutate(
        indicador = paste0(etiquetar_indicador(indicador_id), " (", indicador_id, ")"),
        fuente = etiquetar_fuente(fuente)
      ) %>%
      select(anio, indicador, fuente, valor, valor_texto)
  })
  
  # ------------------------------------------------------------
  # Inmigraciones vs Emigraciones (b12 y b13, sin filtro fuente_mig)
  # ------------------------------------------------------------
  inmigraciones_emigraciones <- reactive({
    tryCatch({
      leer_tabla("
        SELECT anio, indicador_nombre, fuente, valor
        FROM montilla_indicadores_migracion_fix
        WHERE indicador_id IN ('b12','b13')
          AND valor IS NOT NULL
        ORDER BY anio, indicador_nombre;
      ")
    }, error = function(e) {
      data.frame(anio=integer(), indicador_nombre=character(), fuente=character(), valor=double())
    })
  })
  
  output$plot_inmigraciones_emigraciones <- renderPlotly({
    plotly::ggplotly({
    df <- inmigraciones_emigraciones()
    
    validate(
      need(nrow(df) > 0, "No hay datos de inmigraciones/emigraciones.")
    )

    df <- df %>%
      mutate(indicador_label = dplyr::recode(indicador_nombre, "Emigraciones" = "Emigraciones (b12)", "Inmigraciones" = "Inmigraciones (b13)", .default = indicador_nombre))
    
    ggplot(df, aes(x = anio, y = valor, fill = indicador_label)) +
      geom_col(position = "dodge") +
      labs(
        title = "Inmigraciones vs Emigraciones",
        x = "A\u00f1o",
        y = "Personas",
        fill = "Indicador",
        subtitle = "IECA 2003-2021 e INE EMCR 2022-2024"
      ) +
      theme_minimal() +
      theme(plot.margin = margin(5.5, 5.5, 20, 5.5))
    }, tooltip = c("x", "y", "fill"))
  })
    
  
  
  # ------------------------------------------------------------
  # Exportación: tabla final única (long)
  # Descarga un CSV con toda la tabla montilla_indicadores_final_long.
  # ------------------------------------------------------------
  
  
  # -------------------------------
  # Plot: Pirámide
  # -------------------------------
  output$plot_piramide <- renderPlotly({
    plotly::ggplotly({
    df <- piramide_data()
    
    validate(need(nrow(df) > 0, "No hay datos para el año/fuente seleccionados."))
    
    df_plot <- df %>%
      mutate(
        poblacion_plot = ifelse(sexo == "Hombres", -poblacion, poblacion),
        grupo_edad = factor(grupo_edad, levels = unique(grupo_edad[order(edad_min)]))
      )
    
    p <- ggplot(df_plot, aes(x = grupo_edad, y = poblacion_plot, fill = sexo)) +
      geom_col(width = 0.85) +
      coord_flip() +
      scale_y_continuous(labels = function(x) abs(x)) +
      labs(
        title = paste0("Pirámide de población – Año ", unique(df_plot$anio)),
        x = "Grupo de edad (quinquenal)",
        y = "Población",
        fill = "Sexo"
      ) +
      theme_minimal()
    
    if (dplyr::n_distinct(df_plot$fuente) > 1) {
      p <- p + facet_wrap(~fuente)
    }
    
    p
    }, tooltip = c("x", "y", "fill"))
  })
  
  # -------------------------------
  # Paro registrado por sexo (2009-2025)
  # NOTA: Los datos de paro deben estar en tabla paro_registrado_montilla_sexo
  # Si no existen, correr: Scripts/etl_paro_registrado.R
  # -------------------------------
  paro_data <- reactive({
    tryCatch({
      leer_tabla("
        SELECT anio, sexo, paro_registrado
        FROM paro_registrado_montilla_sexo
        WHERE sexo IN ('Hombres', 'Mujeres', 'Ambos sexos')
        ORDER BY anio, sexo;
      ")
    }, error = function(e) {
      # Si la tabla no existe, intenta usar montilla_indicadores_final_long
      # (fallback si el ETL aún no se ejecutó)
      data.frame(anio=integer(), sexo=character(), paro_registrado=double())
    })
  })
  
  output$plot_paro <- renderPlotly({
    plotly::ggplotly({
    df <- paro_data() %>% filter(sexo %in% input$sexo_paro)
    
    validate(need(nrow(df) > 0, "No hay datos de paro registrado."))
    
    ggplot(df, aes(x = anio, y = paro_registrado, color = sexo)) +
      geom_line(linewidth = 1.1) +
      geom_point(size = 2) +
      scale_x_continuous(expand = expansion(mult = c(0.02, 0.14))) +
      labs(
        title = "Paro registrado: Demandantes de empleo",
        x = "Año",
        y = "Demandantes",
        color = "Sexo"
      ) +
      theme_minimal()
    }, tooltip = c("x", "y", "colour"))
  })
  
  # ============================================================
  # BLOQUE: Crecimiento natural (nacimientos - defunciones)
  # ============================================================
  # Fuentes de datos:
  #   - Nacimientos (b14): tabla montilla_indicadores_final_long
  #   - Defunciones (b15 IECA): tabla defunciones_montilla (más robusta)
  # Query usa un FULL OUTER JOIN para capturar todos los años donde
  # haya al menos un indicador (nacimientos o defunciones).
  # ============================================================
  crecimiento_natural <- reactive({
    tryCatch({
      leer_tabla("
        -- NACIMIENTOS: extrae b14 de la tabla final (prioriza IECA)
        WITH nacimientos_rank AS (
          SELECT
            anio,
            valor AS nacimientos,
            fuente,
            ROW_NUMBER() OVER (
              PARTITION BY anio
              ORDER BY CASE
                WHEN fuente = 'IECA' THEN 1
                WHEN fuente = 'SIMA' THEN 2
                ELSE 3
              END
            ) AS rn
          FROM montilla_indicadores_migracion_fix
          WHERE indicador_id = 'b14'
            AND valor IS NOT NULL
        ),
        nacimientos_priorizado AS (
          SELECT anio, nacimientos
          FROM nacimientos_rank
          WHERE rn = 1
        ),
        -- DEFUNCIONES: extrae defunciones desde tabla dedicada (1996-2024)
        defunciones_ieca_local AS (
          SELECT
            anio,
            defunciones
          FROM defunciones_montilla
          WHERE defunciones IS NOT NULL
        )
        -- RESULTADO: full outer join asegura años con datos en cualquiera
        SELECT
          COALESCE(n.anio, d.anio) AS anio,
          n.nacimientos,
          d.defunciones
        FROM nacimientos_priorizado n
        FULL OUTER JOIN defunciones_ieca_local d ON d.anio = n.anio
        ORDER BY anio;
      ") %>%
        mutate(
          anio = as.integer(anio),
          nacimientos = as.numeric(nacimientos),
          defunciones = as.numeric(defunciones)
        )
    }, error = function(e) {
      # Fallback: retorna df vacío si query falla (mensajes de validación lo capturan)
      data.frame(anio=integer(), nacimientos=double(), defunciones=double())
    })
  })
  
  # ============================================================
  # BLOQUE: Renderizado del gráfico de crecimiento natural
  # ============================================================
  # Visualización: dos líneas temporales (nacimientos verde, defunciones rojo)
  # con puntos en cada año para marcar valores exactos.
  # ============================================================
  output$plot_crecimiento_natural <- renderPlotly({
    plotly::ggplotly({
    df <- crecimiento_natural()
    
    # Validaciones: verifica que haya datos suficientes
    validate(need(nrow(df) > 0, "⚠ No hay datos para crecimiento natural."))
    validate(need(any(!is.na(df$nacimientos)), "⚠ No hay nacimientos para graficar."))
    validate(need(any(!is.na(df$defunciones)), "⚠ No hay defunciones para graficar."))
    ultimo_anio <- max(df$anio, na.rm = TRUE)
    df_ultimo <- df %>% filter(anio == ultimo_anio)
    
    # Gráfico: líneas temporales superpuestas (nacimientos + defunciones)
    ggplot(df, aes(x = anio)) +
      # Línea de nacimientos (verde)
      geom_line(aes(y = nacimientos, color = "Nacimientos"), linewidth = 1.1, na.rm = TRUE) +
      # Puntos de nacimientos
      geom_point(aes(y = nacimientos, color = "Nacimientos"), size = 2.5, na.rm = TRUE) +
      # Línea de defunciones (rojo)
      geom_line(aes(y = defunciones, color = "Defunciones"), linewidth = 1.1, na.rm = TRUE) +
      # Puntos de defunciones
      geom_point(aes(y = defunciones, color = "Defunciones"), size = 2.5, na.rm = TRUE) +
      # Paleta de colores: verde para nacimientos, rojo para defunciones
      scale_color_manual(
        values = c("Nacimientos" = "#27ae60", "Defunciones" = "#e74c3c")
      ) +
      scale_x_continuous(expand = expansion(mult = c(0.02, 0.14))) +
      # Etiquetas y títulos
      labs(
        title = "Crecimiento natural: Nacimientos vs Defunciones",
        x = "Año",
        y = "Personas",
        color = "Serie",
        subtitle = "Nacimientos 2006-2024 y defunciones 1996-2024"
      ) +
      # Tema minimalista
      theme_minimal() +
      theme(plot.margin = margin(5.5, 28, 5.5, 5.5)) +
      theme(
        plot.title = element_text(face = "bold", size = 14, hjust = 0.5),
        plot.subtitle = element_text(size = 10, color = "gray50", hjust = 0.5),
        legend.position = "top",
        legend.title = element_text(face = "bold"),
        panel.grid.major = element_line(color = "gray90", linewidth = 0.3),
        panel.grid.minor = element_blank()
      )
    }, tooltip = c("x", "y", "colour"))
  })
  
}

shinyApp(ui, server)


