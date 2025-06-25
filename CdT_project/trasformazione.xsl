﻿<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema">

    <xsl:output method="html" encoding="UTF-8" indent="yes"/>
    <xsl:preserve-space elements="*"/> <!--conserva gli spazi vuoti nel contenuto testuale-->

    <xsl:template match="/"> <!--template della radice per iniziare la trasformazione (punto d'ingresso)-->
        <html>
            <head>
                <title>Progetto Codifica di Testi</title>
                <script src="https://code.jquery.com/jquery-3.7.1.js"></script>
                <script src="https://code.jquery.com/ui/1.13.1/jquery-ui.js"></script>
                <script src="./src/script.js"></script>
                <link href="./src/style.css" rel="stylesheet" type="text/css" />
            </head>

            <body>
                <header> <!--intestazione del sito-->
                    <div>
                        <a href="https://rassegnasettimanale.animi.it/" target="_blank">
                            La Rassegna Settimanale
                        </a>
                    </div>

                    <nav>
                        <div class="navbar">
                            <a href="#">Home</a>
                            <div class="dropdown">
                                <button class="dropbutton">Pagine</button>
                                <div class="dropdown-content">
                                    <xsl:for-each select="//tei:surface"> <!--dropdown menu che genera, per ogni elemento surface, un link al corrispondente id-->
                                        <a href="#{@xml:id}">
                                            <xsl:value-of select="@xml:id"/>
                                        </a>
                                    </xsl:for-each>
                                </div>
                            </div>
                            <a href="#about">About</a>
                        </div>
                    </nav>
                </header>
                

                <div class="desc"> <!--metadati dell'opera-->
                    <h2>Titolo Opera:</h2>
                    <xsl:apply-templates select="//tei:titleStmt"/>

                    <h2>Descrizione Editoriale:</h2>
                    <xsl:apply-templates select="//tei:imprint"/>

                    <h2>Descrizione Manoscritto:</h2>
                    <xsl:apply-templates select="//tei:objectDesc"/>

                    <h2>Descrizione Codifica:</h2>
                    <xsl:apply-templates select="//tei:projectDesc"/>
                </div>

                <div id="fenomeni"> <!--barra dei fenomeni-->
                    <ul class='bottoni_fenomeni'> <!--genera pulsanti in maniera dinamica-->
                        <!--scorro tutti gli elementi-->
                        <xsl:for-each select="//tei:persName | //tei:addName | //tei:placeName | //tei:date | //tei:orgName | //tei:quote | //tei:bibl | //tei:publisher | //tei:seg">
                            <!--per ogni elemento trovato, viene determinato un nome di classe corrispondente-->
                            <xsl:variable name="className">
                                <xsl:choose>
                                    <!--la variabile $className prende il nome dell'elemento corrente-->
                                    <xsl:when test="self::tei:persName">persone</xsl:when> <!--self è il nodo corrente, si cerca persName, va su persName ed esegue self::tei:persName, se true stampa persone; quando false passa al prossimo-->
                                    <xsl:when test="self::tei:addName">epiteti</xsl:when>
                                    <xsl:when test="self::tei:placeName">luoghi</xsl:when>
                                    <xsl:when test="self::tei:date">date</xsl:when>
                                    <xsl:when test="self::tei:orgName">organizzazioni</xsl:when>
                                    <xsl:when test="self::tei:quote">citazioni</xsl:when>
                                    <xsl:when test="self::tei:bibl">bibliografia</xsl:when>
                                    <xsl:when test="self::tei:publisher">editori</xsl:when>
                                    <xsl:when test="self::tei:seg">temi</xsl:when>
                                </xsl:choose>
                            </xsl:variable>

                            <!--check sulle categorie se sono state già create, verifica se l'elemento corrente è il primo del suo tipo incontrato, si assicura che non ci siano duplicati-->
                            <!--preceding::tei:* >>> seleziona tutti gli elementi che si trovano prima del nodo corrente del doc
                                  [name() = name(current())] >>> filtra quelli che hanno lo stesso nome del nodo corrente
                                  count(...) = 0 >> verifica se non c'è altro elemento con lo stesso nome prima-->
                            <xsl:if test="count(preceding::tei:*[name() = name(current())]) = 0"> <!-- se questo è il primo nodo del suo tipo che incontro, allora crea il bottone -->
                                <button type="button" id="{$className}"> <!--genera i pulsanti con un id corrispondente al nome della classe-->
                                    <xsl:value-of select="$className"/> <!--etichetta testuale uguale al valore di $className-->
                                </button>
                            </xsl:if>
                        </xsl:for-each>

                        <!--altri button-->
                        <button type="button" id="alt">forme alternative</button>
                        <button type="button" id="abbr">abbreviazioni</button>
                    </ul>
                </div>

                <div class="text"> <!--contenuto testuale-->
                    <xsl:for-each select="//tei:surface"> <!--ciclo su ogni surface (surface = nodo corrente)-->
                        <h2 id="{@xml:id}"> <!--stampa il nome della pagina (titolo) e lo usa come id per i link interni-->
                            <xsl:value-of select="@xml:id"/>
                        </h2>
                        <div class="container">
                            <!-- lato sinistro (immagine) -->
                            <div class="box">
                                <!--usemap fa riferimento a @xml:id >>> collega l'immagine a una <map> con aree cliccabili,
                                      se sono su <surface xml:id="pagina02">, il valore sarà "pagina02" >>> codice HTML = <img usemap="#pagina02"...
                                      se ho <graphic url="img/pagina02.jpg"/>, l'attributo src sarà <img src="img/pagina02.jpg">,
                                      quindi genero: <img usemap="#pagina02" src="img/pagina02.jpg"/> (associazione img <-> mappa interattiva)-->
                                <img usemap="#{@xml:id}" src="{tei:graphic/@url}"/> <!--collega l'img alla mappa, prende il percorso dell'immagine e mostra l'img della pagina scansionata-->
                                <!--genero la map per la surface (interattività)-->
                                <map id="{@xml:id}">
                                    <!--per ogni elemento zone, produco tag <area>:
                                          rect = rettangolo
                                          coords = coordinate-->
                                    <xsl:for-each select="tei:zone">
                                        <area shape="rect"
                                            coords="{@ulx},{@uly},{@lrx},{@lry}"
                                            style="cursor: help;"
                                            title="{@xml:id}"/>
                                    </xsl:for-each>
                                </map>
                            </div>

                            <!--lato destro (testo)-->
                            <div class="boxtext">
                                <xsl:variable name="currentSurfaceId" select="@xml:id"/> <!--salvo id della surface-->

                                <!--Colonna 1: zone con ulx < 280-->
                                <div class="column column1">
                                    <xsl:for-each select="tei:zone[number(@ulx) &lt; 280]"> <!--seleziono solo le zone con ulx < 280 -->
                                        <xsl:variable name="thisZoneID" select="@xml:id"/> <!--salvo id con variabile $thisZoneID-->
                                        <xsl:apply-templates select="//tei:*[@facs = concat('#',$thisZoneID)]"/> <!--cerco un el qualunque //tei:* che abbia @facs="#thisZoneID"--> 
                                    </xsl:for-each>
                                </div>

                                <!--Colonna 2: zone con ulx >= 280-->
                                <div class="column column2">
                                    <xsl:for-each select="tei:zone[number(@ulx) &gt;= 280]">
                                        <xsl:variable name="thisZoneID" select="@xml:id"/>
                                        <xsl:apply-templates select="//tei:*[@facs = concat('#',$thisZoneID)]"/>
                                    </xsl:for-each>
                                </div>

                            </div>
                            <hr/> <!--linea orizzontale per separare una pagina dall'altra-->
                        </div>
                    </xsl:for-each>
                </div>

                <!--sommario dei fenomeni con link clickabili 
                      select="/" seleziona il nodo radice - l'applicazione del template inizia dall'intero doc;
                      mode: devono essere applicati solo i template definiti con il suo valore;
                      cerca i template che hanno mode="fenomeniSummary-->
                <xsl:apply-templates select="/" mode="fenomeniSummary"/>

                <div id="about">
                    <footer>
                        <h1>INFORMAZIONI PROGETTO:</h1>
                        <div class="container">
                            <div class="box">
                                <h2>Informazioni Edizione:</h2>
                                <xsl:apply-templates select="//tei:editionStmt"/>
                            </div>
                            <div class="box">
                                <h2>Informazioni Pubblicazione:</h2>
                                <xsl:apply-templates select="//tei:publicationStmt"/>
                            </div>
                        </div>
                        <p style="text-align:center">Repository <a href="https://github.com/southmida/">GitHub</a></p>
                    </footer>
                </div>

            </body>

            <div id="scrollTopBtn">▲ Torna su</div>

        </html>
    </xsl:template>

    <!--SOMMARIO FENOMENI-->
    <xsl:template match="/" mode="fenomeniSummary">

        <div id="fenomeniSummary" style="margin:2em 10%; padding:1em; border:1px solid #ccc; border-radius:10px; background-color:#fff;">
            <h2 style="margin-top:0; font-family:'Old Standard TT';">Fenomeni Rilevati</h2>

            <!--raggruppo gli elementi TEI per name()-->
            <xsl:for-each-group select="//tei:persName 
                                         | //tei:addName 
                                         | //tei:placeName 
                                         | //tei:date 
                                         | //tei:orgName 
                                         | //tei:quote 
                                         | //tei:bibl 
                                         | //tei:publisher 
                                         | //tei:seg"
                                 group-by="name()"> <!--li raggruppa in base al loro nome di tag-->

                <xsl:variable name="label">
                    <!--traduce ogni nome di elemento in un'etichetta user-friendly-->
                    <xsl:choose>
                        <xsl:when test="current-grouping-key() = 'persName'">Persone</xsl:when>
                        <xsl:when test="current-grouping-key() = 'addName'">Epiteti</xsl:when>
                        <xsl:when test="current-grouping-key() = 'placeName'">Luoghi</xsl:when>
                        <xsl:when test="current-grouping-key() = 'date'">Date</xsl:when>
                        <xsl:when test="current-grouping-key() = 'orgName'">Organizzazioni</xsl:when>
                        <xsl:when test="current-grouping-key() = 'quote'">Citazioni</xsl:when>
                        <xsl:when test="current-grouping-key() = 'bibl'">Bibliografia</xsl:when>
                        <xsl:when test="current-grouping-key() = 'publisher'">Editori</xsl:when>
                        <xsl:when test="current-grouping-key() = 'seg'">Temi</xsl:when>
                        <xsl:otherwise>Altri</xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>

                <p>
                    <strong><xsl:value-of select="$label"/>: </strong>
                    <!--per ogni elemento in questo gruppo crea un link all'ID nel testo-->
                    <xsl:for-each select="current-group()">

                        <a> <!--crea link-->
                            <xsl:attribute name="href">
                                <!-- usa@ref, altrimenti genera un id e lo usa come ancora-->
                                <xsl:choose>
                                    <xsl:when test="@ref != ''">
                                        <xsl:value-of select="@ref"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="concat('#', generate-id(current()))"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:attribute>
                            <xsl:value-of select="normalize-space(.)"/> <!--toglie spazi iniziali e finali-->
                        </a>
                        <xsl:if test="position() != last()">, </xsl:if> <!--mette una virgola tra i nomi, tranne per l'ultimo-->
                    </xsl:for-each>
                </p>
            </xsl:for-each-group>

        </div>
    </xsl:template>


    <xsl:template match="tei:head">
        <xsl:element name="h2"> <!--dinamico-->
            <xsl:attribute name="id"> <!--crea un attributo id per il titolo-->
                <xsl:value-of select="substring-after(@facs, '#')"/> <!--rimuove #--> 
            </xsl:attribute>
            <xsl:apply-templates select="node()"/> <!--applica il template ai nodi figli dell'elemento <head>, cioè il testo-->
        </xsl:element>
    </xsl:template>

    <xsl:template match="tei:lb"> <!--il template si attiva ogni volta che incontra un elemento <lb/>-->
        <xsl:text> </xsl:text><br/> <!--inserisce uno spazio bianco prima del tag <br/> che manda a capo il testo-->
    </xsl:template>

    <xsl:template match="tei:p">
        <xsl:element name="p"> <!--crea un elemento HTML <p> dinamico-->
            <!--trasforma <p facs="#id1_2paola"> (XML) in <p id="id1_2paola"> (HTML)-->
            <xsl:attribute name="id"> <!--aggiunge un attributo id-->
                <xsl:value-of select="substring-after(@facs, '#')" /> <!--legge il valore dell'attributo facs, estraendo tutto ciò che viene dopo #-->
            </xsl:attribute>
            <xsl:apply-templates
                select="node()" /> <!--elabora tutto ciò che sta dentro l'elemento p-->
        </xsl:element>
    </xsl:template>

    <xsl:template match="tei:cb">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="tei:*"> <!--qualsiasi elemento: applica template anche ai figli / salta il tag attuale e passa ai suoi contenuti-->
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="text()">
        <xsl:value-of select="." disable-output-escaping="yes"/> <!--scrivi nel risultato il valore del nodo attuale / non trasforma i caratteri spieciali in entità HTML (&, <, >)-->
    </xsl:template>

    <xsl:template match="tei:choice">
        <xsl:choose>

            <xsl:when test="tei:orig and tei:reg">
                <span class="choice forma alternativa" id="{generate-id()}">
                    <span class="orig visible">
                        <xsl:value-of select="tei:orig"/> <!--la forma originale è visibile-->
                    </span>
                    <span class="reg hidden" style="color: red;">
                        <xsl:value-of select="tei:reg"/> <!--la forma regolare è nascosta-->
                    </span>
                </span>
            </xsl:when>

            <xsl:when test="tei:abbr and tei:expan">
                <span class="choice abbreviazione" id="{generate-id()}">
                    <span class="abbr visible">
                        <xsl:value-of select="tei:abbr"/>
                    </span>
                    <span class="expan hidden" style="color: blue;">
                        <xsl:value-of select="tei:expan"/>
                    </span>
                </span>
            </xsl:when>

            <xsl:otherwise>
                <span class="choice" id="{generate-id()}">
                    <xsl:apply-templates select="node()"/>
                </span>
            </xsl:otherwise>

        </xsl:choose>
    </xsl:template>

    <xsl:template match="tei:unclear">
        <span class="unclear" title="{@reason}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="tei:titleStmt">
        <div>
            <p><strong>Titolo Principale: </strong> <xsl:value-of select="tei:title[@type='main']"/></p>
            <p><strong>Sottotitolo: </strong> <xsl:value-of select="tei:title[@type='sub']"/></p>
            <p><strong>Autori: </strong> 
                <xsl:for-each select="tei:author/tei:persName">
                    <xsl:value-of select="."/>
                    <xsl:if test="position()!=last()">, </xsl:if> <!--virgola tra autori-->
                </xsl:for-each>
            </p>
        </div>
    </xsl:template>

    <xsl:template match="tei:imprint">
        <div>
            <p><strong>Luogo di Pubblicazione: </strong> <xsl:value-of select="tei:pubPlace"/></p>
            <p><strong>Editore: </strong> <xsl:value-of select="tei:publisher"/></p>
            <p><strong>Data: </strong> <xsl:value-of select="tei:date"/></p>
        </div>
    </xsl:template>


    <xsl:template match="tei:publicationStmt">
        <div>
            <p><strong>Pubblicato da: </strong> <xsl:value-of select="tei:publisher"/></p>
            <p><strong>Luogo e data di Pubblicazione: </strong> <xsl:value-of select="tei:pubPlace"/>, <xsl:value-of select="tei:date"/></p>
            <p><strong>Disponibilità: </strong> <xsl:apply-templates select="tei:availability"/></p>
        </div>
    </xsl:template>

    <xsl:template match="tei:objectDesc/tei:supportDesc">
        <div>
            <p><strong>Supporto: </strong> <xsl:value-of select="tei:support"/></p>
            <p><strong>Condizioni: </strong> <xsl:value-of select="tei:condition"/></p>
        </div>
    </xsl:template>

    <xsl:template match="tei:layoutDesc/tei:layout">
        <div>
            <p><strong>Layout:</strong> <xsl:value-of select="."/></p>
        </div>
    </xsl:template>

    <xsl:template match="tei:encodingDesc">
        <div>
            <p><xsl:apply-templates/></p>
        </div>
    </xsl:template>
    
    <xsl:template match="tei:editionStmt">
        <div>
            <p><strong>Edizione: </strong> <xsl:apply-templates select="tei:edition"/></p>
            <xsl:apply-templates select="tei:respStmt"/>
        </div>
    </xsl:template>

    <xsl:template match="tei:respStmt">
        <div>
            <p><strong><xsl:value-of select="tei:resp"/> </strong>
               <xsl:value-of select="tei:persName"/>
            </p>
        </div>
    </xsl:template>

    <xsl:template match="tei:div">
        <span class="zone" id="{@xml:id}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="tei:surface">
        <!--trasforma <graphic> in <img>-->
        <img usemap="#{current()/@xml:id}"/> <!--prende id del nodo corrente <surface> e genera <img usemap="#surface1">-->
        <!--crea <map> con stesso ID di surface-->
        <map id="{current()/@xml:id}">
            <xsl:apply-templates select="tei:zone"/>
        </map>
    </xsl:template>

    <xsl:template match="tei:zone">
    <area shape="rect"
            coords="{@ulx},{@uly},{@lrx},{@lry}"
            style="cursor: help;"
            title="{@xml:id}"/>
    </xsl:template>

    <xsl:template match="tei:persName">
      <span class="persName"> <!--crea un elemento HTML <span> con la classe "persName"-->
        <xsl:attribute name="id"> <!--aggiunge un attributo id al span, serve per i link interni-->
          <xsl:choose>
            <xsl:when test="@ref != ''"> <!--se il nome della persona ha attributo @ref-->
              <xsl:value-of select="substring-after(@ref, '#')"/> <!--allora l'id dello span sarà tutto quello dopo #-->
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="generate-id()"/> <!--altrimenti lo genera-->
            </xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
        <xsl:apply-templates/> <!--applica template ai figli, mostra il contenuto del nome all'interno dello span-->
      </span>
    </xsl:template>

    <xsl:template match="tei:addName">
        <a class="addName" id="{generate-id()}">
            <xsl:apply-templates/>
        </a>
    </xsl:template>

    <xsl:template match="tei:placeName">
      <span class="placeName">
        <xsl:attribute name="id">
          <xsl:choose>
            <xsl:when test="@ref != ''">
              <xsl:value-of select="substring-after(@ref, '#')"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="generate-id()"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
        <xsl:apply-templates/>
      </span>
    </xsl:template>

    <xsl:template match="tei:date">
        <a class="date" id="{generate-id()}">
            <xsl:apply-templates/>
        </a>
    </xsl:template>

    <xsl:template match="tei:orgName">
        <span class="orgName">
        <xsl:attribute name="id">
          <xsl:choose>
            <xsl:when test="@ref != ''">
              <xsl:value-of select="substring-after(@ref, '#')"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="generate-id()"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
        <xsl:apply-templates/>
      </span>
    </xsl:template>

    <xsl:template match="tei:quote">
        <a class="quote" id="{generate-id()}">
            <xsl:apply-templates/>
        </a>
    </xsl:template>

    <xsl:template match="tei:bibl">
        <span class="bibl" id="{generate-id()}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="tei:publisher">
        <a class="publisher" id="{generate-id()}">
            <xsl:apply-templates/>
        </a>
    </xsl:template>

    <xsl:template match="tei:seg">
        <span class="temi" id="{generate-id()}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="tei:note[@place='foot']">
        <div class="foot" id="{@xml:id}">
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="*[@rend='italic']">
        <span style="font-style: italic;">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

</xsl:stylesheet>