{**
 * plugins/generic/htmlArticleGalley/templates/display.tpl
 * (this is a modified copy of templates/frontend/objects/article_details.tpl)
 *
 * Copyright (c) 2014-2021 Simon Fraser University
 * Copyright (c) 2003-2021 John Willinsky
 * Copyright (c) 2020-2021 State and University Library Hamburg 
 * Distributed under the GNU GPL v3. For full terms see the file docs/COPYING.
 *
 * @brief View of an Article which displays all details about the article.
 *  Expected to be primary object on the page.
 *
 * Many journals will want to add custom data to this object, either through
 * plugins which attach to hooks on the page or by editing the template
 * themselves. In order to facilitate this, a flexible layout markup pattern has
 * been implemented. If followed, plugins and other content can provide markup
 * in a way that will render consistently with other items on the page. This
 * pattern is used in the .main_entry column and the .entry_details column. It
 * consists of the following:
 *
 * <!-- Wrapper class which provides proper spacing between components -->
 * <div class="item">
 *     <!-- Title/value combination -->
 *     <div class="label">Abstract</div>
 *     <div class="value">Value</div>
 * </div>
 *
 * All styling should be applied by class name, so that titles may use heading
 * elements (eg, <h3>) or any element required.
 *
 * <!-- Example: component with multiple title/value combinations -->
 * <div class="item">
 *     <div class="sub_item">
 *         <div class="label">DOI</div>
 *         <div class="value">12345678</div>
 *     </div>
 *     <div class="sub_item">
 *         <div class="label">Published Date</div>
 *         <div class="value">2015-01-01</div>
 *     </div>
 * </div>
 *
 * <!-- Example: component with no title -->
 * <div class="item">
 *     <div class="value">Whatever you'd like</div>
 * </div>
 *
 * Core components are produced manually below, but can also be added via
 * plugins using the hooks provided:
 *
 * Templates::Article::Main
 * Templates::Article::Details
 *
 * @uses $article Submission This article
 * @uses $publication Publication The publication being displayed
 * @uses $firstPublication Publication The first published version of this article
 * @uses $currentPublication Publication The most recently published version of this article
 * @uses $issue Issue The issue this article is assigned to
 * @uses $section Section The journal section this article is assigned to
 * @uses $categories Category The category this article is assigned to
 * @uses $primaryGalleys array List of article galleys that are not supplementary or dependent
 * @uses $supplementaryGalleys array List of article galleys that are supplementary
 * @uses $keywords array List of keywords assigned to this article
 * @uses $pubIdPlugins Array of pubId plugins which this article may be assigned
 * @uses $licenseTerms string License terms.
 * @uses $licenseUrl string URL to license. Only assigned if license should be
 *   included with published submissions.
 * @uses $ccLicenseBadge string An image and text with details about the license
 *}
{include file="frontend/components/header.tpl" pageTitleTranslated=$article->getLocalizedTitle()|escape}
{if $section}
	{include file="frontend/components/breadcrumbs_article.tpl" currentTitle=$section->getLocalizedTitle()}
{else}
	{include file="frontend/components/breadcrumbs_article.tpl" currentTitleKey="common.publication"}
{/if}


{* sub-hh / set to 1 -> no sidebar *}
{assign var=isFullWidth value=1}
<!-- +++ embedded HTML template +++ -->

<article class="obj_article_details">

	{* Indicate if this is only a preview *}
	{if $publication->getData('status') !== $smarty.const.STATUS_PUBLISHED}
		<div class="cmp_notification notice">
			{capture assign="submissionUrl"}{url page="workflow" op="access" path=$article->getId()}{/capture}
			{translate key="submission.viewingPreview" url=$submissionUrl}
		</div>
		{* Notification that this is an old version *}
	{elseif $currentPublication->getId() !== $publication->getId()}
		<div class="cmp_notification notice">
			{capture assign="latestVersionUrl"}{url page="article" op="view" path=$article->getBestId()}{/capture}
			{translate key="submission.outdatedVersion"
					datePublished=$publication->getData('datePublished')|date_format:$dateFormatShort
					urlRecentVersion=$latestVersionUrl|escape
				}
		</div>
	{/if}

	<h1 class="page_title">
		{$publication->getLocalizedTitle()|escape}
	</h1>

	{if $publication->getLocalizedData('subtitle')}
		<h2 class="subtitle">
			{$publication->getLocalizedData('subtitle')|escape}
		</h2>
	{/if}

	{if $publication->getData('authors')}
		<section class="item authors">
			<h2 class="pkp_screen_reader">{translate key="article.authors"}</h2>
			<ul class="authors">
				{foreach from=$publication->getData('authors') item=author}
					<li>
						<span class="name">
							{$author->getFullName()|escape}
						</span>
						{if $author->getLocalizedData('affiliation')}
							<span class="affiliation">
								{$author->getLocalizedData('affiliation')|escape}
								{if $author->getData('rorId')}
									<a href="{$author->getData('rorId')|escape}">{$rorIdIcon}</a>
								{/if}
							</span>
						{/if}
						{if $author->getData('orcid')}
							<span class="orcid">
								{$orcidIcon}
								<a href="{$author->getData('orcid')|escape}" target="_blank">
									{$author->getData('orcid')|escape}
								</a>
							</span>
						{/if}
					</li>
				{/foreach}
			</ul>
		</section>
	{/if}

	<div class="row">
		<div class="main_entry">

			{* Provide download link *}
			{* <div class="inline_html_galley_download">
			<a class="obj_galley_link file" href="{url page="article" op="download" path=$article->getBestArticleId()|to_array:$galley->getBestGalleyId()}">
				{translate key="common.download"}
			</a>
		</div> *}

			{* Show article inline *}
			<div class="inline_html">
				{$embeddedHtmlGalley}
			</div>

			{* already included in HTML galley: *}
			{* Authors, orcid, ror *}
			{* DOI (requires plugin) *}
			{* Keywords *}
			{* Abstract *}

			{call_hook name="Templates::Article::Main"}

			{* Author biographies *}
			{assign var="hasBiographies" value=0}
			{foreach from=$publication->getData('authors') item=author}
				{if $author->getLocalizedData('biography')}
					{assign var="hasBiographies" value=$hasBiographies+1}
				{/if}
			{/foreach}
			{if $hasBiographies}
				<section class="item author_bios">
					<h2 class="label">
						{if $hasBiographies > 1}
							{translate key="submission.authorBiographies"}
						{else}
							{translate key="submission.authorBiography"}
						{/if}
					</h2>
					{foreach from=$publication->getData('authors') item=author}
						{if $author->getLocalizedData('biography')}
							<section class="sub_item">
								<h3 class="label">
									{if $author->getLocalizedData('affiliation')}
										{capture assign="authorName"}{$author->getFullName()|escape}{/capture}
										{capture assign="authorAffiliation"}<span
											class="affiliation">{$author->getLocalizedData('affiliation')|escape}</span>{/capture}
										{translate key="submission.authorWithAffiliation" name=$authorName affiliation=$authorAffiliation}
									{else}
										{$author->getFullName()|escape}
									{/if}
								</h3>
								<div class="value">
									{$author->getLocalizedData('biography')|strip_unsafe_html}
								</div>
							</section>
						{/if}
					{/foreach}
				</section>
			{/if}

			{* References *}
			{if $parsedCitations || $publication->getData('citationsRaw')}
				<section class="item references">
					<h2 class="label">
						{translate key="submission.citations"}
					</h2>
					<div class="value">
						{if $parsedCitations}
							{foreach from=$parsedCitations item="parsedCitation"}
								<p>{$parsedCitation->getCitationWithLinks()|strip_unsafe_html}
									{call_hook name="Templates::Article::Details::Reference" citation=$parsedCitation}</p>
							{/foreach}
						{else}
							{$publication->getData('citationsRaw')|escape|nl2br}
						{/if}
					</div>
				</section>
			{/if}

		</div><!-- .main_entry -->

		<div class="entry_details">

			{* sub-hh *}
			<div class="item backlink">
				<a href="{url page="article" op="view" path=$article->getId()}"><span
						class="fa fa-arrow-left"></span>{translate key="plugins.generic.embeddedHtmlGalley.backLink"}</a>
			</div>

			{* Article/Issue cover image *}
			{if $publication->getLocalizedData('coverImage') || ($issue && $issue->getLocalizedCoverImage())}
				<div class="item cover_image">
					<div class="sub_item">
						{if $publication->getLocalizedData('coverImage')}
							{assign var="coverImage" value=$publication->getLocalizedData('coverImage')}
							<img src="{$publication->getLocalizedCoverImageUrl($article->getData('contextId'))|escape}"
								alt="{$coverImage.altText|escape|default:''}">
						{else}
							<a href="{url page="issue" op="view" path=$issue->getBestIssueId()}">
								<img src="{$issue->getLocalizedCoverImageUrl()|escape}"
									alt="{$issue->getLocalizedCoverImageAltText()|escape|default:''}">
							</a>
						{/if}
					</div>
				</div>
			{/if}

			{* Article Galleys *}
			{if $primaryGalleys}
				<div class="item galleys">
					<h2 class="pkp_screen_reader">
						{translate key="submission.downloads"}
					</h2>
					<ul class="value galleys_links">
						{foreach from=$primaryGalleys item=galley}
							{if $galley->isPdfGalley()}
								<li>
									{include file="frontend/objects/galley_link.tpl" parent=$article publication=$publication galley=$galley purchaseFee=$currentJournal->getData('purchaseArticleFee') purchaseCurrency=$currentJournal->getData('currency')}
								</li>
							{/if}
						{/foreach}
					</ul>
				</div>
			{/if}
			{if $supplementaryGalleys}
				<div class="item galleys">
					<h3 class="pkp_screen_reader">
						{translate key="submission.additionalFiles"}
					</h3>
					<ul class="value supplementary_galleys_links">
						{foreach from=$supplementaryGalleys item=galley}
							<li>
								{include file="frontend/objects/galley_link.tpl" parent=$article publication=$publication galley=$galley isSupplementary="1"}
							</li>
						{/foreach}
					</ul>
				</div>
			{/if}

			{if $publication->getData('datePublished')}
				<div class="item published">
					<section class="sub_item">
						<h2 class="label">
							{translate key="submissions.published"}
						</h2>
						<div class="value">
							<span>{$firstPublication->getData('datePublished')|date_format:$dateFormatShort}</span>
						</div>
					</section>
				</div>
			{/if}

			{* How to cite *}
			{if $citation}
				<div class="item citation">
					<section class="sub_item citation_display">
						<h2 class="label">
							{translate key="submission.howToCite"}
						</h2>
						<div class="value">
							<div id="citationOutput" role="region" aria-live="polite">
								{$citation}
							</div>
							<div class="citation_formats">
								<button class="cmp_button citation_formats_button" aria-controls="cslCitationFormats"
									aria-expanded="false" data-csl-dropdown="true">
									{translate key="submission.howToCite.citationFormats"}
								</button>
								<div id="cslCitationFormats" class="citation_formats_list" aria-hidden="true">
									<ul class="citation_formats_styles">
										{foreach from=$citationStyles item="citationStyle"}
											<li>
												<a aria-controls="citationOutput"
													href="{url page="citationstylelanguage" op="get" path=$citationStyle.id params=$citationArgs}"
													data-load-citation
													data-json-href="{url page="citationstylelanguage" op="get" path=$citationStyle.id params=$citationArgsJson}">
													{$citationStyle.title|escape}
												</a>
											</li>
										{/foreach}
									</ul>
									{if count($citationDownloads)}
										<div class="label">
											{translate key="submission.howToCite.downloadCitation"}
										</div>
										<ul class="citation_formats_styles">
											{foreach from=$citationDownloads item="citationDownload"}
												<li>
													<a
														href="{url page="citationstylelanguage" op="download" path=$citationDownload.id params=$citationArgs}">
														<span class="fa fa-download"></span>
														{$citationDownload.title|escape}
													</a>
												</li>
											{/foreach}
										</ul>
									{/if}
								</div>
							</div>
						</div>
					</section>
				</div>
			{/if}

			{* Issue article appears in *}
			{if $issue || $section || $categories}
				<div class="item issue">

					{if $issue}
						<section class="sub_item">
							<h2 class="label">
								{translate key="issue.issue"}
							</h2>
							<div class="value">
								<a class="title" href="{url page="issue" op="view" path=$issue->getBestIssueId()}">
									{$issue->getIssueIdentification()}
								</a>
							</div>
						</section>
					{/if}

					{if $section}
						<section class="sub_item">
							<h2 class="label">
								{translate key="section.section"}
							</h2>
							<div class="value">
								{$section->getLocalizedTitle()|escape}
							</div>
						</section>
					{/if}

					{if $categories}
						<section class="sub_item">
							<h2 class="label">
								{translate key="category.category"}
							</h2>
							<div class="value">
								<ul class="categories">
									{foreach from=$categories item=category}
										<li><a
												href="{url router=$smarty.const.ROUTE_PAGE page="catalog" op="category" path=$category->getPath()|escape}">{$category->getLocalizedTitle()|escape}</a>
										</li>
									{/foreach}
								</ul>
							</div>
						</section>
					{/if}
				</div>
			{/if}

			{* PubIds (requires plugins) *}
			{foreach from=$pubIdPlugins item=pubIdPlugin}
				{if $pubIdPlugin->getPubIdType() == 'doi'}
					{continue}
				{/if}
				{assign var=pubId value=$article->getStoredPubId($pubIdPlugin->getPubIdType())}
				{if $pubId}
					<section class="item pubid">
						<h2 class="label">
							{$pubIdPlugin->getPubIdDisplayType()|escape}
						</h2>
						<div class="value">
							{if $pubIdPlugin->getResolvingURL($currentJournal->getId(), $pubId)|escape}
								<a id="pub-id::{$pubIdPlugin->getPubIdType()|escape}"
									href="{$pubIdPlugin->getResolvingURL($currentJournal->getId(), $pubId)|escape}">
									{$pubIdPlugin->getResolvingURL($currentJournal->getId(), $pubId)|escape}
								</a>
							{else}
								{$pubId|escape}
							{/if}
						</div>
					</section>
				{/if}
			{/foreach}

			{* Licensing info *}
			{if $currentContext->getLocalizedData('licenseTerms') || $publication->getData('licenseUrl')}
				<div class="item copyright">
					<h2 class="label">
						{translate key="submission.license"}
					</h2>
					{if $publication->getData('licenseUrl')}
						{if $ccLicenseBadge}
							{if $publication->getLocalizedData('copyrightHolder')}
								<p>{translate key="submission.copyrightStatement" copyrightHolder=$publication->getLocalizedData('copyrightHolder') copyrightYear=$publication->getData('copyrightYear')}
								</p>
							{/if}
							{$ccLicenseBadge}
						{else}
							<a href="{$publication->getData('licenseUrl')|escape}" class="copyright">
								{if $publication->getLocalizedData('copyrightHolder')}
									{translate key="submission.copyrightStatement" copyrightHolder=$publication->getLocalizedData('copyrightHolder') copyrightYear=$publication->getData('copyrightYear')}
								{else}
									{translate key="submission.license"}
								{/if}
							</a>
						{/if}
					{/if}
					{$currentContext->getLocalizedData('licenseTerms')}
				</div>
			{/if}

			{call_hook name="Templates::Article::Details"}

		</div><!-- .entry_details -->
	</div><!-- .row -->

</article>

{include file="frontend/components/footer.tpl"}