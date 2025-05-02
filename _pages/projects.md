---
layout: page # 或者 projects 布局
title: Projects
permalink: /projects/
nav: true
nav_order: 2 
---

<div class="projects">
  {% if site.enable_masonry %}
    <div class="grid-sizer"></div>
  {% endif %}
  
  {% assign sorted_projects = site.projects | sort: "importance" %} 
  <!-- 循环遍历 projects 集合中的所有项目 -->
  {% for project in sorted_projects %} 
    <!-- 为每个项目调用 include 文件 -->
    {% include projects.html %} 
  {% endfor %}
</div> 