

window.setObjects = function(objs) {
  setTabs();
  var style = document.createElement('style');
  var css = 
    '.tabHeader:focus { text-decoration: none !important; }' +
    '.tabIcon:before {' +
    '  position: absolute;' +
    '  left: 0;' +
    '  top: 0;' +
    '  width: 100%;' +
    '  height: 100%;' +
    '  border-bottom: 4px solid #fff;' +
    '  content: \'\';' +
    '  z-index: 1;' +
    '}' +
    '.tabItem.slds-active .tabIcon:before {' +
    '  border-bottom: 0px solid #fff;' +
    '}' +
    '.tabHeader span.title,' +
    '.tabHeader lightning-primitive-icon {' +
    '  z-index: 100;' +
    '  position: relative;' +
    '}' +
    '.tabItem .close,' +
    '.tabItem .slds-dropdown-trigger {' +
    '  z-index: 100;' +
    '  position: relative;' +
    '};';
  objs.forEach(function(o) {
    css += setObject(o);
  });
  style.innerHTML = css;
  window.document.head.appendChild(style);
}

window.setObject = function(obj) {
  var label = obj.Object_Label__c;
  var name = obj.Object_Name__c.replace(/_/g, ' ');
  var bg = obj.Tab_Background_Colour__c;
  var text = obj.Tab_Text_Colour__c;
  var alt = obj.Object_Name__c;
  var plural = obj.Object_Plural__c;
  var css = 
    '.tabIcon[title="' + name + '"] ~ span,' +
    '.tabIcon[title="' + name + '"] svg {' +
    '  color: ' + bg + ' !important;' +
    '  fill: ' + bg + ' !important;' +
    '}' +
    '.tabIcon[title="' + name + '"]:before {' +
    '  border-bottom: 4px solid ' + bg + ' !important;' +
    '}' +
    '.tabItem.slds-is-active .tabIcon[title="' + name + '"]:before, ' +
    '.tabItem.slds-active .tabIcon[title="' + name + '"]:before {' +
    '  border-bottom: none !important;' +
    '  background: ' + bg + ' !important;' +
    '}' +
    '.tabItem.slds-is-active .tabIcon[title="' + name + '"] ~ span,' +
    '.tabItem.slds-is-active .tabIcon[title="' + name + '"] svg,' +
    '.tabItem.slds-active .tabIcon[title="' + name + '"] ~ span,' +
    '.tabItem.slds-active .tabIcon[title="' + name + '"] svg,' +
    '.menuItem[data-itemid="' + alt + '"] svg {' +
    '  color: ' + text + ' !important;' +
    '  fill: ' + text + ' !important;' +
    '}' +
    '.menuItem[data-itemid="' + alt + '"] lightning-icon {' +
    '  background: ' + bg + ' !important;' +
    '}' +
    '.slds-icon[title="' + label + '"],' +
    '.slds-icon[title="' + plural + '"],' +
    '.forceEntityIcon[title="' + label + '"],' +
    '.forceEntityIcon[title="' + plural + '"] {' +
    '  background: ' + bg + ' !important;' +
    '}' +
    '.tabItem.slds-active .tabHeader[title="' + name + '"] ~ .close svg,' +
    '.tabItem.slds-active .tabHeader[title="' + name + '"] ~ .slds-dropdown-trigger svg,' +
    '.tabItem.slds-is-active .tabHeader[title="' + name + '"] ~ .close svg,' +
    '.tabItem.slds-is-active .tabHeader[title="' + name + '"] ~ .slds-dropdown-trigger svg {' +
    '  color: ' + text + ' !important;' +
    '}';
  return css;
}

window.setTabs = function(set) {
  Array.from(window.document.getElementsByTagName('*')).forEach(function(e) {
    if (e.className != null && e.className != undefined) {
      try {
        if (e.className.indexOf('icon') != -1) {
          e.parentElement.parentElement.setAttribute('title', e.title);
        }
        if (e.className.indexOf('tabIcon') != -1) {
          e.parentElement.setAttribute('title', e.title);
        }
        if (e.className.indexOf('itemTitle') != -1 && !set) {
          if (e.innerText == 'CustomTabs') {
            e.parentElement.parentElement.parentElement.parentElement.className += ' slds-hide';
          }
        }
      } catch(e) {}
    }
  });
  setTimeout(function() {
    setTabs(true);
  }, 1000);
}