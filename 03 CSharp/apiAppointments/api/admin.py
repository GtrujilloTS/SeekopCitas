from django.contrib import admin
from .models import sepa_current_version,sepa_companies,sepa_branch,sepa_user_groups,user,sepa_log
# Register your models here.

@admin.register(sepa_current_version)
class sepa_current_version_admin(admin.ModelAdmin):
    fields = ['nombre','features','fixes']
    list_display = ['nombre','features']
    list_filter = ['nombre','features','fixes']
    search_fields = ['nombre']

admin.site.register(sepa_companies)
admin.site.register(sepa_branch)
admin.site.register(sepa_user_groups)
admin.site.register(user)
admin.site.register(sepa_log)
