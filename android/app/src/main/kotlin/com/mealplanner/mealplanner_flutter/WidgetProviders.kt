package com.mealplanner.mealplanner_flutter

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.graphics.BitmapFactory
import android.net.Uri
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

/**
 * Base de los tres widgets de la pantalla de inicio.
 *
 * Los tres funcionan igual: la app dibuja su contenido con Flutter, lo guarda
 * como PNG y deja la ruta del archivo en las preferencias compartidas del
 * plugin. Aquí solo hay que cargar esa imagen y decir adónde lleva el toque.
 *
 * Se hace así para que el widget salga con el tema de color y el modo oscuro
 * que el usuario haya elegido dentro de la app: con `RemoteViews` "de verdad"
 * habría que reescribir en XML el anillo de calorías, las barras y toda la
 * paleta de Material 3, y mantenerlos sincronizados a mano.
 *
 * @param imageKey clave bajo la que la app guarda la ruta del PNG.
 * @param tabIndex pestaña de la app que se abre al tocarlo (ver `HomeTab`).
 */
abstract class ImageWidgetProvider(
    private val imageKey: String,
    private val tabIndex: Int,
) : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        // Si el archivo ya no está (copia de seguridad restaurada, limpieza de
        // caché…), `decodeFile` devuelve null y se enseña el texto de aviso en
        // vez de un hueco en blanco.
        val bitmap = widgetData.getString(imageKey, null)?.let {
            BitmapFactory.decodeFile(it)
        }

        val pendingIntent = HomeWidgetLaunchIntent.getActivity(
            context,
            MainActivity::class.java,
            Uri.parse("mealplanner://tab/$tabIndex"),
        )

        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_card).apply {
                if (bitmap != null) {
                    setImageViewBitmap(R.id.widget_image, bitmap)
                    setViewVisibility(R.id.widget_image, View.VISIBLE)
                    setViewVisibility(R.id.widget_placeholder, View.GONE)
                } else {
                    setViewVisibility(R.id.widget_image, View.GONE)
                    setViewVisibility(R.id.widget_placeholder, View.VISIBLE)
                }
                setOnClickPendingIntent(R.id.widget_root, pendingIntent)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}

/** Calorías y proteína de hoy. Abre la pestaña "Hoy". */
class TodayWidgetProvider : ImageWidgetProvider("widget_today_image", 0)

/** La comida que toca y la siguiente. Abre la pestaña "Hoy" para registrarla. */
class NextMealWidgetProvider : ImageWidgetProvider("widget_next_image", 0)

/** Lo que falta por comprar. Abre la pestaña "Compra". */
class ShoppingWidgetProvider : ImageWidgetProvider("widget_shopping_image", 3)
