class MainController < ApplicationController
  def index
    @ur=UR.national
    @mp=MP.national.open
    @pu=PU.national
    @upd_ur = Update.find('ur')
    @upd_pu = Update.find('pu')
    @nav = [{ t('nav-first-page') => '/'}]
  end

  def city
    @city= City.find(params['id'])
    @upd_ur = Update.find('ur')
    @upd_pu = Update.find('pu')
    @nav = [{ @city.name => "#"},{ @city.state.name => "/state/#{@city.state.abbreviation}"},{ t('nav-first-page') => '/'}]
  end

  def state
    @state= State.find_by abbreviation: params['id']
    @upd_ur = Update.find('ur')
    @upd_pu = Update.find('pu')
    @nav = [{ @state.name => "#"},{ t('nav-first-page') => '/'}]
  end

  def staff
    @places = PU.blocked.national
    @upd_pu = Update.find('pu')
    @nav = [{'Staff' => '#'},{ t('nav-first-page') => '/'}]
  end

  def pus
    @places = PU.national.editable
    @upd_pu = Update.find('pu')
    @nav = [{t('unapproved-places') => "#"},{ t('nav-first-page') => '/'}]
  end

  def mps
    @mps = MP.national
    @upd_mp = Update.find('ur')
    @nav = [{t('mps') => "#"},{ t('nav-first-page') => '/'}]
  end
end
