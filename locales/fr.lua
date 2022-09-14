local Translations = {
    error = {
        need_chips = 'Vous avez besoin de %{Chipsamount} jetons pour tourner la roue!',
        time = 'Revenez plus tard pour tourner la roue!',
    },
    success = {
        You_Won = 'Vous avez gagné %{prize}',
    },
    general = {
        pistol = 'un calibre .50!',
        cash = '$300,000 en Cash!',
        Marked = 'des billets marqués!',
        chips = '25,000 jetons de casino!',
        sandwich_water = '.... des Sandwich et de l\'eau?',
        money = '$ %{money_amount}!',
        car = 'une voiture!',
        Spin_Wheel = 'Tourner la roue: %{wheel_amount} jetons',
        sender = 'The Diamond Casino',
        subject = 'Votre nouvelle voiture!',
        message = 'Votre nouvelle voiture vous attend au Parking du Motel!'
    },
}

if GetConvar('qb_locale', 'en') == 'fr' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
  end
