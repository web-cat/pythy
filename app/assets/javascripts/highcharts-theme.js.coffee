# Define these as local variables so they can be changed easily,
# instead of scattering them about the theme hash below.


# This font family should match the one in bootstrap_and_overrides.
fontFamily = '"Source Sans Pro", "Helvetica Neue", Helvetica, Arial, sans-serif'

# Text colors.
textColor = '#333'
subtextColor = '#666'

# Accent colors, the same as those in global.css.
blue = 'rgb(30, 163, 255)'
red = 'rgb(167, 0, 13)'
green = 'rgb(20, 152, 46)'
purple = '#8200a5'
orange = '#f64e19'
teal = '#17b8b6'
gold = 'rgb(250, 192, 0)'
gray = 'rgb(83, 83, 83)'

# Set the global options.
Highcharts.setOptions
  colors: [ blue, red, green, purple, orange, teal, gold, gray ],

  chart:
    backgroundColor: 'white'
    animation:
      duration: 250

  plotOptions:
    series:
      animation:
        duration: 250

  title:
    style:
      color: textColor,
      font: "16px #{fontFamily}",
      fontWeight: 600

  subtitle:
    style:
      color: subtextColor,
      font: "12px #{fontFamily}",
      fontWeight: 400

  xAxis:
    title:
      style:
        color: subtextColor,
        font: "12px #{fontFamily}"
    labels:
      style:
        color: subtextColor,
        font: "12px #{fontFamily}"

  yAxis:
    title:
      style:
        color: subtextColor,
        font: "12px #{fontFamily}"
    labels:
      style:
        color: subtextColor,
        font: "12px #{fontFamily}"

  legend:
    itemStyle:
      font: "12px #{fontFamily}",
      color: textColor
    itemHoverStyle:
      color: blue
