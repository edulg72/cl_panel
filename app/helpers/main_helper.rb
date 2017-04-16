module MainHelper
  def type_ur(type)
    ur = {6 => t('ur.type_6'),7 => t('ur.type_7'),8 => t('ur.type_8'),9 => t('ur.type_9'),10 => t('ur.type_10'),11 => t('ur.type_11'),12 => t('ur.type_12'),13 => t('ur.type_13'),14 => t('ur.type_14'),15 => t('ur.type_15'),16 => t('ur.type_16'),18 => t('ur.type_18'),19 => t('ur.type_19'),21 => t('ur.type_21'),22 => t('ur.type_22'),23 => t('ur.type_23')}
    return ur[type]
  end

  def icon_ur(type)
    icon = {6 => "fa-share", 7 => "fa-envelope", 8 => "fa-code-fork", 9 => "fa-circle-o-notch", 10 => "fa-exclamation-triangle", 11 => "fa-minus-circle", 12 => "fa-arrows", 13 => "fa-exclamation-triangle", 14 => "fa-exchange", 15 => "fa-sign-out", 16 => "fa-eraser", 18 => "fa-tree", 19 => "fa-flag", 21 => "fa-exclamation-triangle", 22 => "fa-exclamation-triangle", 23 => "fa-dashboard"}
    return icon[type]
  end

  def type_mp(type)
    problem = { 1 => t('mp.type_1'), 2 => t('mp.type_2'), 3 => t('mp.type_3'), 5 => t('mp.type_5'), 6 => t('mp.type_6'), 7 => t('mp.type_7'), 8 => t('mp.type_8'), 10 => t('mp.type_10'), 11 => t('mp.type_11'), 12 => t('mp.type_12'), 13 => t('mp.type_13'), 14 => t('mp.type_14'), 15 => t('mp.type_15'), 16 => t('mp.type_16'), 17 => t('mp.type_17'), 19 => t('mp.type_19'), 20 => t('mp.type_20'), 21 => t('mp.type_21'), 22 => t('mp.type_22'), 50 => t('mp.type_50'), 51 => t('mp.type_51'), 52 => t('mp.type_52'), 53 => t('mp.type_53'), 70 => t('mp.type_70'), 71 => t('mp.type_71'), 101 => t('mp.type_101'), 102 => t('mp.type_102'), 103 => t('mp.type_103'), 104 => t('mp.type_104'), 105 => t('mp.type_105'), 106 => t('mp.type_106'), 200 => t('mp.type_200'), 300 => t('mp.type_300')}
    return problem[type]
  end

  def icon_mp(type)
    icon = { 1 => "", 2 => "", 3 => "", 5 => "", 6 => "", 7 => "", 8 => "", 10 => "", 11 => "", 12 => "", 13 => "", 14 => "", 15 => "", 16 => "", 17 => "fa-map-marker", 19 => "", 20 => "", 21 => "", 22 => "", 50 => "", 51 => "fa-thumbs-down", 52 => "", 53 => "", 70 => "", 71 => "", 101 => "", 102 => "", 103 => "", 104 => "", 105 => "", 106 => "", 200 => "", 300 => ""}
    return icon[type]
  end

  def type_pu(type,subtype)
    tp = case type
    when 'IMAGE' then t('pu.image')
    when 'VENUE' then t('pu.venue')
    when 'REQUEST' then (subtype == 'UPDATE' ? t('pu.request.update') : (subtype == 'DELETE' ? t('pu.request.delete') : (subtype == 'FLAG' ? t('pu.request.flag') : t('pu.request.unknown'))))
      else 0
    end
    return tp
  end

  def icon_pu(type,subtype)
    tp = case type
    when 'IMAGE' then 'fa-picture-o'
    when 'VENUE' then 'fa-asterisk'
    when 'REQUEST' then (subtype == 'UPDATE' ? 'fa-refresh' : (subtype == 'DELETE' ? 'fa-trash' : (subtype == 'FLAG' ? 'fa-flag' : 'fa-question')))
      else 0
    end
    return tp
  end
end
