<#ftl output_format="plainText">
<#assign requiredActionsText><#if requiredActions??><#list requiredActions><#items as reqActionItem>${msg("requiredAction.${reqActionItem}")}<#sep>, </#sep></#items></#list></#if></#assign>
<#assign fullName = (((user.firstName)!"") + " " + ((user.lastName)!""))?trim>
<#assign onlyPasswordUpdate = requiredActions?? && requiredActions?size == 1 && requiredActions?first == "UPDATE_PASSWORD">
<#-- linkExpiration ist in Minuten. Ganze Stunden selbst formatieren ("24 Stunden" statt Keycloaks "1 Tag"). -->
<#if linkExpiration gte 60 && linkExpiration % 60 == 0><#assign expiryHours = (linkExpiration / 60)?int><#assign expiry = (expiryHours == 1)?then(msg("executeActionsExpiryOneHour"), msg("executeActionsExpiryHours", expiryHours?c))><#else><#assign expiry = linkExpirationFormatter(linkExpiration)></#if>
<#if fullName?has_content>${msg("executeActionsSalutationNamed", fullName)}<#else>${msg("executeActionsSalutationAnonymous")}</#if>

<#if onlyPasswordUpdate>${msg("executeActionsPasswordBody", link, expiry)}<#else>${msg("executeActionsGenericBody", link, requiredActionsText, expiry)}</#if>
