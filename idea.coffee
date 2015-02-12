{route, navigate, path, exec, layout, region, view} = trifl
{div, ul, li, img} = tagg
{iif, eq} = fnuc

route ->
    appview.top topnav 'home'
    appview.main hero
    exec onRoute
    path '/news', ->
        appview.top topnav 'news'
        if exec isItem
            appview.main newsitem
        else
            appview.main newslist
    path '/aboutus', ->
        appview.top topnav 'aboutus'
        appview.main aboutus

onRoute = (p, q) ->
    # involved for each route

isItem = (p, q) ->
    # determine whether p is item

appview = layout ->
    div class:'appview', ->
        div region('top')
        div region('main')

topnav = view (sel) ->
    nav = [
        {title:'Home', id:'home'}
        {title:'News', id:'news'}
        {title:'About Us', id:'aboutus'}
    ]
    ul class:'topnav', ->
        li iif(eq(n.id, sel), class:'selected'), n.title for n in nav

hero = view ->
    img class:'heroimg', src:'/bigpic.jpg'

newslist = view ->
    # ... draw list of news

newsitem = view (item) ->
    # ... draw item


action 'update-searchtext', text

handle 'update-searchtext', (text, callback) ->
    # update model1...
    # update model2...
