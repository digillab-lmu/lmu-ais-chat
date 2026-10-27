<#outputformat "plainText">
<#assign requiredActionsText><#if requiredActions??><#list requiredActions><#items as reqActionItem>${msg("requiredAction.${reqActionItem}")}<#sep>, </#sep></#items></#list></#if></#assign>
<#assign fullName = (((user.firstName)!"") + " " + ((user.lastName)!""))?trim>
<#assign onlyPasswordUpdate = requiredActions?? && requiredActions?size == 1 && requiredActions?first == "UPDATE_PASSWORD">
<#-- linkExpiration ist in Minuten. Ganze Stunden selbst formatieren ("24 Stunden" statt Keycloaks "1 Tag"). -->
<#if linkExpiration gte 60 && linkExpiration % 60 == 0><#assign expiryHours = (linkExpiration / 60)?int><#assign expiry = (expiryHours == 1)?then(msg("executeActionsExpiryOneHour"), msg("executeActionsExpiryHours", expiryHours?c))><#else><#assign expiry = linkExpirationFormatter(linkExpiration)></#if>
</#outputformat>

<#import "template.ftl" as layout>
<@layout.emailLayout>
<#-- Der Name stammt aus dem Benutzerkonto und wird deshalb HTML-escaped, bevor er in den Text eingesetzt wird. -->
<p><#if fullName?has_content>${kcSanitize(msg("executeActionsSalutationNamed", fullName?esc?markup_string))?no_esc}<#else>${msg("executeActionsSalutationAnonymous")}</#if></p>
<#if onlyPasswordUpdate>
${kcSanitize(msg("executeActionsPasswordBodyHtml", link, expiry))?no_esc}
<#else>
${kcSanitize(msg("executeActionsGenericBodyHtml", link, requiredActionsText, expiry))?no_esc}
</#if>
</@layout.emailLayout>
