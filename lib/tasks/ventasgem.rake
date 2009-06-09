namespace :ventasgem do

  task :ensure_development_mode do
    puts "This task is forbidden in #{Rails.env} mode" and exit unless Rails.env == 'development'
  end

  desc "Resets and initializes the development database"
  task :reset => %w(ensure_development_mode db:migrate:reset)

  namespace :init do

    desc "Resets de database and loads initial data for development"
    task :development => %w(
      reset
      environment
      countries
      account_for_development
      admin_for_development
      salesmen_for_development
      customers_for_development
      offers_for_development
    )

    task :account_for_development do
      Account.create!(:short_name => 'test')
    end

    task :admin_for_development do
      puts "creating administrator for development"
      test = Account.first
      u = test.users.build(
        :email => 'admin@test.com',
        :name  => 'Administrator',
        :password => 'V3ntasG3m',
        :password_confirmation => 'V3ntasG3m'
      )
      u.administrator = true
      u.salesman      = false
      u.save!
    end

    task :salesmen_for_development do
      puts "creating salesmen for development"
      test = Account.first

      u = test.users.build(
        :email => 'antonio@test.com',
        :name  => 'Antonio Amador García',
        :password => 'ventasgem',
        :password_confirmation => 'ventasgem'
      )
      u.administrator = false
      u.salesman      = true
      u.save!

      u = test.users.build(
        :email => 'candela@test.com',
        :name  => 'Candela Serrano de las Heras',
        :password => 'ventasgem',
        :password_confirmation => 'ventasgem'
      )
      u.administrator = false
      u.salesman      = true
      u.save!

      u = test.users.build(
        :email => 'manuel@test.com',
        :name  => 'Manuel Rodríguez Aguilar',
        :password => 'ventasgem',
        :password_confirmation => 'ventasgem'
      )
      u.administrator = false
      u.salesman      = true
      u.save!

      u = test.users.build(
        :email => 'alberto@test.com',
        :name  => 'Alberto Llamazares Ansón',
        :password => 'ventasgem',
        :password_confirmation => 'ventasgem'
      )
      u.administrator = false
      u.salesman      = true
      u.save!
    end

    task :customers_for_development => :countries do
      puts "creating customers for development"
      test = Account.first
      test.customers.create(
        :name => 'Básculas Fernández',
        :cif  => 'B-62522289'
      ).create_address(
        :street1     => 'Arizala 13, bajos',
        :city        => 'Deixebre',
        :province    => 'A Coruña',
        :postal_code => '15706',
        :country     => Country.spain
      )

      test.customers.create(
        :name => 'Laboratorios Laredo',
        :cif  => 'A-84095256'
      ).create_address(
        :street1     => 'Vallespir 37',
        :city        => 'Villanueva de Gómez',
        :province    => 'Ávila',
        :postal_code => '05005',
        :country     => Country.spain
      )

      test.customers.create(
        :name => 'Reyab Químicos',
        :cif  => 'A-60912508'
      ).create_address(
        :street1     => 'Enric Granados 126',
        :city        => 'Barcelona',
        :province    => 'Barcelona',
        :postal_code => '08045',
        :country     => Country.spain
      )

      test.customers.create(
        :name => 'GMB Electrónicos',
        :cif  => 'A-29073806'
      ).create_address(
        :street1     => 'Llobregat, 63, bajos',
        :city        => "L'Hospitalet de Llobregat",
        :province    => 'Barcelona',
        :postal_code => '08904',
        :country     => Country.spain
      )

      test.customers.create(
        :name => 'Agip España',
        :cif  => 'A-28188464'
      ).create_address(
        :street1     => 'Anabel Segura, 16',
        :street2     => 'Edificio Vega Norte I',
        :city        => 'Alcobendas',
        :province    => 'Madrid',
        :postal_code => '28108',
        :country     => Country.spain
      )

      test.customers.create(
        :name => 'Enric Gomà',
        :cif  => '38387101D'
      ).create_address(
        :street1     => 'Provença, 214, 6√® 2a',
        :city        => 'Barcelona',
        :province    => 'Barcelona',
        :postal_code => '08036',
        :country     => Country.spain
      )

      test.customers.create(
        :name => 'Almacenes FNAC',
        :cif  => 'A-80/500200'
      ).create_address(
        :street1     => 'Paseo de la Finca, 1',
        :street2     => 'Bloque 11, 2a Planta',
        :city        => 'Pozuelo de Alarcón',
        :province    => 'Madrid',
        :postal_code => '28223',
        :country     => Country.spain
      )
    end

    task :offers_for_development => [:salesmen_for_development, :customers_for_development] do
      puts "creating offers for development"
      test = Account.first

      peticion   = test.custom_statuses.find_by_name_normalized("peticion")
      presentada = test.custom_statuses.find_by_name_normalized("presentada")
      ganadora   = test.custom_statuses.find_by_name_normalized("ganadora")
      perdida    = test.lost_status

      antonio = test.users.find_by_email("antonio@test.com")
      candela = test.users.find_by_email("candela@test.com")
      manuel  = test.users.find_by_email("manuel@test.com")

      fernandez = test.customers.find_by_cif('B-62522289')
      agip      = test.customers.find_by_cif('A-28188464')
      fnac      = test.customers.find_by_cif('A-80/500200')
      reyab     = test.customers.find_by_cif('A-60912508')

      p = test.offers.build(
        :customer    => fernandez,
        :name        => 'Cámaras en cadena de supermercados',
        :amount      => 20000,
        :next_action => 'Comer con el director (Fermín Gutiérrez)',
        :status      => presentada,
        :deal_date   => Date.today + 7
      )
      p.salesman = antonio
      p.save!

      p = test.offers.build(
        :customer    => agip,
        :name        => 'Vigilancia en Gran Premio',
        :amount      => 78676,
        :next_action => 'Llamar a Juan Prieto, contacto en pasada feria',
        :status      => peticion,
        :deal_date   => Date.today + 30
      )
      p.salesman = antonio
      p.save!

      p = test.offers.build(
        :customer    => fnac,
        :name        => 'Revisar instalación en puertas de servicio',
        :amount      => 7245,
        :next_action => 'Confirmar avance de las instalaciones',
        :status      => perdida,
        :deal_date   => Date.today
      )
      p.salesman = candela
      p.save!
      
      p = test.offers.build(
        :customer    => reyab,
        :name        => 'Destinar director de seguridad',
        :amount      => 50000,
        :next_action => 'Hablar con Menéndez del puesto',
        :status      => ganadora,
        :deal_date   => Date.today - 5
      )
      p.salesman = manuel
      p.save!      
    end
    
    desc "Loads the COUNTRIES table, this task is idempotent"
    task :countries => :environment do
      puts "initializing table of countries"
      [
        "Afganistán",
        "Islas Åland",
        "Albania",
        "Alemania",
        "Andorra",
        "Angola",
        "Anguilla",
        "Antártida",
        "Antigua y Barbuda",
        "Antillas Holandesas",
        "Arabia Saudí",
        "Argelia",
        "Argentina",
        "Armenia",
        "Aruba",
        "Australia",
        "Austria",
        "Azerbaiyán",
        "Bahamas",
        "Bahréin",
        "Bangladesh",
        "Barbados",
        "Bielorrusia",
        "Bélgica",
        "Belice",
        "Benin",
        "Bermudas",
        "Bhután",
        "Bolivia",
        "Bosnia y Herzegovina",
        "Botsuana",
        "Isla Bouvet",
        "Brasil",
        "Brunéi",
        "Bulgaria",
        "Burkina Faso",
        "Burundi",
        "Cabo Verde",
        "Islas Caimán",
        "Camboya",
        "Camerún",
        "Canadá",
        "República Centroafricana",
        "Chad",
        "República Checa",
        "Chile",
        "China",
        "Chipre",
        "Islas Cocos",
        "Colombia",
        "Comoras",
        "República del Congo",
        "República Democrática del Congo",
        "Islas Cook",
        "Corea del Norte",
        "Corea del Sur",
        "Costa de Marfil",
        "Costa Rica",
        "Croacia",
        "Cuba",
        "Dinamarca",
        "Dominica",
        "República Dominicana",
        "Ecuador",
        "Egipto",
        "El Salvador",
        "Emiratos Árabes Unidos",
        "Eritrea",
        "Eslovaquia",
        "Eslovenia",
        "España",
        "Estados Unidos",
        "Islas ultramarinas de Estados Unidos",
        "Estonia",
        "Etiopía",
        "Islas Feroe",
        "Filipinas",
        "Finlandia",
        "Fiyi",
        "Francia",
        "Gabón",
        "Gambia",
        "Georgia",
        "Islas Georgias del Sur y Sandwich del Sur",
        "Ghana",
        "Gibraltar",
        "Granada",
        "Grecia",
        "Groenlandia",
        "Guadalupe",
        "Guam",
        "Guatemala",
        "Guayana Francesa",
        "Guernesey",
        "Guinea",
        "Guinea Ecuatorial",
        "Guinea-Bissau",
        "Guyana",
        "Haití",
        "Islas Heard y McDonald",
        "Honduras",
        "Hong Kong",
        "Hungría",
        "India",
        "Indonesia",
        "Irán",
        "Iraq",
        "Irlanda",
        "Islandia",
        "Israel",
        "Italia",
        "Jamaica",
        "Japón",
        "Jersey",
        "Jordania",
        "Kazajistán",
        "Kenia",
        "Kirguistán",
        "Kiribati",
        "Kuwait",
        "Laos",
        "Lesotho",
        "Letonia",
        "Líbano",
        "Liberia",
        "Libia",
        "Liechtenstein",
        "Lituania",
        "Luxemburgo",
        "Macao",
        "ARY Macedonia",
        "Madagascar",
        "Malasia",
        "Malawi",
        "Maldivas",
        "Malí",
        "Malta",
        "Islas Malvinas",
        "Isla de Man",
        "Islas Marianas del Norte",
        "Marruecos",
        "Islas Marshall",
        "Martinica",
        "Mauricio",
        "Mauritania",
        "Mayotte",
        "México",
        "Micronesia",
        "Moldavia",
        "Mónaco",
        "Mongolia",
        "Montserrat",
        "Mozambique",
        "Myanmar",
        "Namibia",
        "Nauru",
        "Isla de Navidad",
        "Nepal",
        "Nicaragua",
        "Níger",
        "Nigeria",
        "Niue",
        "Isla Norfolk",
        "Noruega",
        "Nueva Caledonia",
        "Nueva Zelanda",
        "Omán",
        "Países Bajos",
        "Pakistán",
        "Palau",
        "Palestina",
        "Panamá",
        "Papúa Nueva Guinea",
        "Paraguay",
        "Perú",
        "Islas Pitcairn",
        "Polinesia Francesa",
        "Polonia",
        "Portugal",
        "Puerto Rico",
        "Qatar",
        "Reino Unido",
        "Reunión",
        "Ruanda",
        "Rumania",
        "Rusia",
        "Sahara Occidental",
        "Islas Salomón",
        "Samoa",
        "Samoa Americana",
        "San Cristóbal y Nevis",
        "San Marino",
        "San Pedro y Miquelón",
        "San Vicente y las Granadinas",
        "Santa Helena",
        "Santa Lucía",
        "Santo Tomé y Príncipe",
        "Senegal",
        "Serbia y Montenegro",
        "Seychelles",
        "Sierra Leona",
        "Singapur",
        "Siria",
        "Somalia",
        "Sri Lanka",
        "Suazilandia",
        "Sudáfrica",
        "Sudán",
        "Suecia",
        "Suiza",
        "Surinam",
        "Svalbard y Jan Mayen",
        "Tailandia",
        "Taiwán",
        "Tanzania",
        "Tayikistán",
        "Territorio Británico del Océano Índico",
        "Territorios Australes Franceses",
        "Timor Oriental",
        "Togo",
        "Tokelau",
        "Tonga",
        "Trinidad y Tobago",
        "Túnez",
        "Islas Turcas y Caicos",
        "Turkmenistán",
        "Turquía",
        "Tuvalu",
        "Ucrania",
        "Uganda",
        "Uruguay",
        "Uzbekistán",
        "Vanuatu",
        "Ciudad del Vaticano",
        "Venezuela",
        "Vietnam",
        "Islas Vírgenes Británicas",
        "Islas Vírgenes de los Estados Unidos",
        "Wallis y Futuna",
        "Yemen",
        "Yibuti",
        "Zambia",
        "Zimbabue"
   ].each do |name|
        Country.find_or_create_by_name(name)
      end
    end
  end

  desc "(Re)assigns colors to all statuses and users"
  task :assign_colors => [:assign_colors_to_statuses, :assign_colors_to_users] do
  end

  task :assign_colors_to_statuses => :environment do
    puts "(re)assigning colors to all statuses"
    assign_colors_to_klass(Status)
  end

  task :assign_colors_to_users => :environment do
    puts "(re)assigning colors to all users"
    assign_colors_to_klass(User)
  end

  def assign_colors_to_klass(klass)
    klass.update_all('color = NULL')
    klass.all.each do |record|
      record.send(:assign_color)
      record.save(false)
    end
  end
end