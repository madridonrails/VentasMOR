# Hack to prototype in Spanish, we'll add l10n-simplified when dates etc. are localized.
ActiveRecord::Errors.default_error_messages = {
  :inclusion           => "no está incluido en la lista",
  :exclusion           => "está reservado",
  :invalid             => "no es válido",
  :confirmation        => "no coincide con la confirmación",
  :accepted            => "debe ser aceptado",
  :empty               => "no puede estar vacío",
  :blank               => "no puede estar en blanco",# alternate, formulation: "is required"
  :too_long            => "es demasiado largo (el máximo es %d caracteres)",
  :too_short           => "es demasiado corto (el mínimo es %d caracteres)",
  :wrong_length        => "no tiene la longitud requerida (debería ser de %d caracteres)",
  :taken               => "ya está ocupado",
  :not_a_number        => "no es un número",
  :error_translation   => "error",
  :error_header        => "%s no permite guardar %s",
  :error_subheader     => "Ha habido problemas con los siguientes campos:"
}
