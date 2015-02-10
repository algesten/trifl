{route, navigate, path, exec, layout, view} = trifl
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

route '/news/thehives-51423'

appview = layout ->
    div class:'appview', ->
        div class:'top'
        div class:'main'

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

# a view. the function is the redraw function which is passed the
# model for that view.
#
# topnav = view (sel) ->
#   ...
#
# topnav.el # DOM element
#
# topnav('home')
#
# draws the view into topnav.el
