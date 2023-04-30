/**
 * A jQuery plugin autocomplete
 * @author Gozoro <gozoro@yandex.ru>
 * @version 1.0.1
 */
 
 // https://packagist.org/packages/gozoro/jquery-autocompleter

;(function($)
{
	'use strict';

	if(typeof($) == 'undefined')
	{
		console.warn('Required jQuery.');
		return;
	}


	$.fn.autocompleter = function(variants, options)
	{
		var defaultMatchValue = function(item, index){return item;}

		options = $.extend({
            maxResults: 0,
			minChars: 1,
			timeout: 500,
			matchRegexp: function(value, escape){return RegExp(escape(value), 'i')},
			matchValue:  defaultMatchValue,
			itemDisplay: options['matchValue'] || defaultMatchValue,
			itemValue:   null,
			hiddenValue: '',
			emptyValue: '',
			ajaxData: function(value){return {value:value};}
        }, options);

		var _this = this;


		return this.each(function()
		{
			var mouseLock       = false;
			var useHiddenInput  = (typeof options['itemValue'] == 'function');
			var searchInput     = $(this);
			var oldValue        = searchInput.val().trim();
			var hiddenValue     = options['hiddenValue'] || options['emptyValue'];
			var hiddenInput     = $('<input type="hidden" value="'+hiddenValue+'">');
			var resultPanel     = $('<div>').addClass('autocompleter-result');
			var resultPanelVisible = false;
			searchInput.after(resultPanel);



			function reposition()
			{
				var pos = searchInput.position();

				resultPanel.css({
					left: pos.left,
					top: pos.top + searchInput.outerHeight(),
					width: searchInput.outerWidth()
				});
			}

			window.addEventListener('resize', reposition);
			document.fonts.ready.then(reposition);

			reposition();



			if(useHiddenInput)
			{
				hiddenInput.attr('name', searchInput.attr('name') );
				searchInput.removeAttr('name').after(hiddenInput);
			}

			resultPanel.unselect = function()
			{
				resultPanel.find('.selected').removeClass('selected');
				return this;
			}

			resultPanel.show = function()
			{
				$.fn.show.apply(this, arguments);

				resultPanelVisible = true;
				resultPanel.unselect().scrollTop(0).children().first().addClass('selected');
				_this.trigger('resultShow', {});
			}

			resultPanel.hide = function()
			{
				$.fn.hide.apply(this, arguments);

				resultPanelVisible = false;
				_this.trigger('resultHide', {});
			}

			searchInput.blur(function()
			{
				resultPanel.hide();
			});

			searchInput.click(function()
			{
				search( searchInput.val(), 1);
			});

			searchInput.on('paste', function(event)
			{
				search( event.originalEvent.clipboardData.getData('text'), 1);
			});


			resultPanel.mouseout(function()
			{
				if(!mouseLock)
				{
					resultPanel.unselect();
				}
			});

			resultPanel.reselect = function(row)
			{
				mouseLock = false;
				resultPanel.unselect();
				$(row).addClass('selected');
			}

			resultPanel.addResultItem = function(item, itemIndex)
			{
				var matchValue = options['matchValue'](item, itemIndex);

				if(useHiddenInput)
				{
					var itemValue = options['itemValue'](item, itemIndex);
				}
				else
				{
					var itemValue = matchValue;
				}

				var resultRow = $('<div>').addClass('autocompleter-item')
							.attr('data-match-value', matchValue)
							.attr('data-value', itemValue)
							.html( options['itemDisplay'](item, itemIndex) )
							.mousedown(function(event)
							{
								event.preventDefault(); // This prevents the element from being hidden by .blur before it's clicked
							})
							.click(function()
							{
								resultPanel.selectVariant($(this)).hide();
							})
							.mouseover(function()
							{
								if(!mouseLock)
								{
									resultPanel.reselect(this);
								}
							})
							.mousemove(function()
							{
								if(mouseLock)
								{
									resultPanel.reselect(this);
								}
							})
							;

							resultPanel.append(resultRow);
			}

			searchInput.keyup(function()
			{
				inputDelay(function()
				{
					search( searchInput.val() );
				});
			});

			searchInput.keydown(function(event)
			{
				switch(event.which)
				{
					case 38: pressUpArrow(event); return;
					case 40: pressDownArrow(event); return;
					case 13: pressEnter(event); return;
					case 9:  resultPanel.hide(); return; // Tab
					case 27: resultPanel.hide(); return; // Esc
				}
			});

			resultPanel.selectVariant = function(variant)
			{
				var matchValue = variant.data('match-value');
				var itemValue = variant.data('value');

				if(useHiddenInput)
					hiddenInput.val(itemValue);

				searchInput.val( matchValue );
				oldValue = matchValue;
				resultPanel.empty();

				return this;
			}

			function pressEnter(event)
			{
				event.preventDefault();

				var selectedVariant = resultPanel.find('.selected').first();

				if(selectedVariant.length)
				{
					resultPanel.unselect().selectVariant(selectedVariant);
				}

				resultPanel.hide();
			}

			function pressUpArrow(event)
			{
				if(resultPanelVisible)
				{
					event.preventDefault();
					mouseLock = true;
					var selectedItem = resultPanel.find('.selected').first();

					if(selectedItem.length)
					{
						resultPanel.unselect();

						var prevItem = selectedItem.prev();

						if(prevItem.length)
						{
							var itemTop = prevItem.addClass('selected').position().top ;
							var offset  = resultPanel.position().top - prevItem.innerHeight();

							if(itemTop < offset)
							{
								resultPanel.scrollTop( resultPanel.scrollTop() + offset + itemTop );
							}
							return;
						}
					}

					resultPanel.scrollTop( resultPanel.get(0).scrollHeight ).children().last().addClass('selected');
				}
			}


			function pressDownArrow()
			{
				if(resultPanelVisible)
				{
					event.preventDefault();
					mouseLock = true;
					var selectedItem = resultPanel.find('.selected').first();

					if(selectedItem.length)
					{
						resultPanel.unselect();

						var nextItem = selectedItem.next();

						if(nextItem.length)
						{
							var panelHeight = resultPanel.outerHeight() ;
							var itemHeight  = nextItem.addClass('selected').innerHeight();
							var itemBottom  = nextItem.position().top + itemHeight;

							if(itemBottom > panelHeight)
							{
								resultPanel.scrollTop( resultPanel.scrollTop() + itemHeight - resultPanel.position().top - panelHeight + itemBottom );
							}
							return;
						}
					}

					resultPanel.scrollTop( 0 ).children().first().addClass('selected');
				}
				else
				{
					if(resultPanel.children().length)
					{
						resultPanel.show();
					}
				}
			}


			function escapeRegExp(str)
			{
				return str.replace(/[.*+\-?^${}()|[\]\\]/g, '\\$&'); // $& means the whole matched string
			}


			var locks = [];
			function inputDelay(callback)
			{
				locks.push(1);
				setTimeout(function()
				{
					locks.pop();
					if(!locks.length)
					{
						callback();
					}
				}, options['timeout']);
			}


			function search(value, forceShow)
			{
				value = value.trim();

				if(value === oldValue)
				{
					if(forceShow && resultPanel.children().length)
					{
					    resultPanel.show();
					}

					return;
				}

				hiddenInput.val(options['emptyValue']);
				oldValue = value;
				resultPanel.empty();

				if(!value || value.length < options['minChars'])
				{
					resultPanel.hide();
					return;
				}

				_this.trigger('beforeSearch', {val:value});

				if(variants.constructor.name == 'String')
				{
					var oPar = new Object()
						oPar[ 'value' ] = options['ajaxData'](value)

					$.get( variants, options['ajaxData'](value), function(response){ filtering(value, response); } );
					//$.get( variants, oPar, function(u){ console.log(u) } );
					// $.get(variants, options['ajaxData'](value), function(response){ filtering(value, response); });
				}
				else
				{

					filtering(value, variants);
				}
			}


			function filtering(value, variants)
			{
			
			console.log( 'FILTERING', value )
			console.log( variants )
				var regexp = options['matchRegexp'](value, escapeRegExp);
				var fullregexp = RegExp('^'+escapeRegExp(value)+'$', regexp.flags);
				var i = 0;

				for(var itemIndex in variants)
				{
console.log( itemIndex )				
					var item = variants[itemIndex];
console.log( item )					
					var matchValue = options['matchValue'](item, itemIndex);
console.log( matchValue )
					if(useHiddenInput)
						var itemValue = options['itemValue'](item, itemIndex);
					else
						var itemValue = matchValue;

					if(matchValue.match(fullregexp))
						hiddenInput.val(itemValue);

					if(matchValue.match(regexp) && (options['maxResults'] <= 0 || i < options['maxResults']))
					{
						resultPanel.addResultItem(item, itemIndex);
						i++
					}
				}

				_this.trigger('afterSearch', {});

				if(resultPanel.children().length)
					resultPanel.show();
				else
					resultPanel.hide();
			}
		}); // end each
	};
}(jQuery));