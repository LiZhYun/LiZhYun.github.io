---
layout: page
permalink: /publications/
title: Publications
# description: publications by categories in reversed chronological order. 
# years: [2024,2023,2022]
nav: true
nav_order: 1
---
<!-- _pages/publications.md -->
<!-- <div class="publications"> -->

<div class="publications about_pub">
  {% bibliography -f papers %}
</div>
<!-- {%- for y in page.years %}
  <h3 class="year">{{y}}</h3>
  {% bibliography -f papers -q @*[year={{y}}]* %}
{% endfor %} -->
