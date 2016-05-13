/*!
 * Start Bootstrap - Creative Bootstrap Theme (http://startbootstrap.com)
 * Code licensed under the Apache License v2.0.
 * For details, see http://www.apache.org/licenses/LICENSE-2.0.
 */
!function(t){"use strict";t("a.page-scroll").bind("click",function(e){var i=t(this);t("html, body").stop().animate({scrollTop:t(i.attr("href")).offset().top-50},1250,"easeInOutExpo"),e.preventDefault()}),t("body").scrollspy({target:".navbar-fixed-top",offset:51}),t(".navbar-collapse ul li a").click(function(){t(".navbar-toggle:visible").click()}),t("h1").fitText(1.2,{minFontSize:"35px",maxFontSize:"65px"}),t("#mainNav").affix({offset:{top:100}}),(new WOW).init()}(jQuery);